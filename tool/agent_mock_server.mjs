// Local-only strict Chat Completions simulator + static release server.
// It never logs headers, bodies, conversations or credentials.
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
const root = path.resolve(process.argv[2] || 'build/agent-review');
const port = Number(process.argv[3] || 8787);
let sequence = 0;
function strictHistory(messages) {
  let pending = new Set();
  for (const message of messages) {
    if (message.role === 'tool') {
      if (!pending.delete(message.tool_call_id)) return false;
    } else {
      if (pending.size) return false;
      pending = new Set((message.tool_calls || []).map(c=>c.id));
    }
  }
  return !pending.size;
}
function completion(payload) {
  const messages = payload.messages || [];
  if (!strictHistory(messages)) throw new Error('invalid_tool_history');
  const call = (name,args) => ({tool_calls:[{id:`qa-${++sequence}`,type:'function',function:{name,arguments:JSON.stringify(args)}}]});
  if (payload.tools?.[0]?.function?.name === 'ping') return call('ping',{});
  const user = messages.findLast(m=>m.role==='user')?.content || '';
  const tools = messages.filter(m=>m.role==='tool');
  const last = tools.length ? JSON.parse(tools.at(-1).content) : null;
  if (last?.status === 'committed') return call('analyze_training',{days:7});
  if (last?.status === 'rejected') return {content:'## 没有修改数据\n\n你拒绝了提案，原计划保持不变。'};
  if (last?.status === 'conflicted') return {content:'数据在确认前发生了变化，本次修改没有执行。请重新读取后生成新提案。'};
  if (last?.template && last?.expectedDigest) {
    const workout = last.workouts[0];
    return call('propose_revise_plan',{templateId:last.template.id,expectedDigest:last.expectedDigest,edits:[
      {op:'replace',path:`${workout.path}/exercises/0/restSeconds`,value:90},
      {op:'replace',path:`${workout.path}/exercises/0/stages/0/sets/0/targetReps`,value:10},
    ]});
  }
  if (last?.asOf) return {content:'## 本次任务已完成\n\n修改已按你的确认提交；原计划和训练进度均保留，操作历史支持撤销。\n\n| 分析范围 | 结果 |\n| --- | --- |\n| 最近7天 | 当前没有训练记录 |\n| 当前计划 | 沈师五分划的安全副本 |\n\n**提示：** 这是本地模拟服务的验收结果，不是真实模型建议。'};
  if (tools.length) return {content:'本地工具返回了结构化结果。请根据上方状态继续。'};
  return /计划|plan|修改/.test(user) ? call('get_active_plan',{limit:1}) : call('analyze_training',{days:7});
}
const server = http.createServer(async(req,res)=>{
  if(req.method==='POST' && req.url==='/v1/agent/chat-completions') {
    let raw='';
    try {
      for await(const chunk of req) { raw+=chunk; if(raw.length>524288) throw new Error('request_too_large'); }
      const envelope=JSON.parse(raw);
      if(req.headers.authorization!=='Bearer synthetic-qa-session') { res.writeHead(401);res.end('{}');return; }
      const payload=envelope.payload;
      const result=completion(payload);
      res.writeHead(200,{'content-type':'text/event-stream','cache-control':'no-store'});
      if(result.tool_calls) {
        const delta={tool_calls:result.tool_calls.map((c,index)=>({index,...c}))};
        res.write(`data: ${JSON.stringify({choices:[{delta,finish_reason:'tool_calls'}]})}\n\n`);
      } else {
        for(const text of result.content.match(/.{1,12}|\n/gu) || []) {
          if(res.destroyed) return;
          res.write(`data: ${JSON.stringify({choices:[{delta:{content:text}}]})}\n\n`);
          await new Promise(resolve=>setTimeout(resolve,12));
        }
        res.write('data: {"choices":[{"delta":{},"finish_reason":"stop"}]}\n\n');
      }
      res.end('data: [DONE]\n\n');
    } catch(_) { if(!res.headersSent) res.writeHead(400,{'content-type':'application/json'});res.end('{"error":{"code":"invalid_request","message":"Invalid synthetic request"}}'); }
    return;
  }
  const requested=decodeURIComponent(new URL(req.url,'http://localhost').pathname);
  const filename=path.resolve(root,`.`+requested+(requested.endsWith('/')?'index.html':''));
  if(!filename.startsWith(root+path.sep)) {res.writeHead(403);res.end();return;}
  if(!fs.existsSync(filename) || !fs.statSync(filename).isFile()) {res.writeHead(404);res.end();return;}
  try {
    const mime={'.html':'text/html','.js':'text/javascript','.wasm':'application/wasm','.json':'application/json','.ttf':'font/ttf','.otf':'font/otf','.png':'image/png','.svg':'image/svg+xml'};
    res.writeHead(200,{'content-type':mime[path.extname(filename)]||'application/octet-stream','cache-control':'no-store'});
    fs.createReadStream(filename).pipe(res);
  } catch(_) {res.writeHead(404);res.end();}
});
server.listen(port,'127.0.0.1',()=>process.stdout.write(`Synthetic Agent QA ready at http://127.0.0.1:${port}\n`));
