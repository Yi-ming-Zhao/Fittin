# Fittin v1.1.2

## Agent 计划修改修复

- 修复确认修改计划时，嵌套计划快照转换失败的问题。该错误与网络无关。
- 参考 [pi agent-core 的运行循环](https://github.com/earendil-works/pi/blob/main/packages/agent/src/agent-loop.ts)，分离模型结束、工具结果与运行错误；参数有误时允许模型在原有安全上限内修正，不直接终止整轮。
- 截断或断线的响应不再被当成成功，不执行不完整的工具调用。确认、取消、出错后的工具消息保持配对，便于继续对话。
- 计划按页读取，可只提交需要变动的字段，减少长计划引发的输出截断和等待。预览显示实际字段差异，继续保留逐次确认、过期检测、进度保护和撤销。

## 对话体验

- AI 回复支持 Markdown 标题、列表、加粗、表格、引用和代码块，适配五套主题和手机窄屏。
- 去掉底部三个数据洞察框；仍可在对话中分析训练数据。
- 出错时直接显示错误信息，不再留下空白 Agent 输出框。已有的非空内容仍然保留。
- Markdown 不自动加载图片，不执行 HTML，只允许用户点击打开 HTTP(S) 链接。

## 更新说明

- 版本 `1.1.2+23`，使用原有 Android 稳定签名，可覆盖更新，无需卸载。
- 不改变存储结构，不清除原计划、训练数据、登录或原生 Agent 配置。Web Key 仍只保存在当前页面内存中。
- 使用真实内置计划、实际传输解析器与模拟供应商响应验证；未使用真实 DeepSeek 账号 Key 进行本轮复测。

---

Agent plan confirmation now normalizes nested snapshots correctly. The pi-inspired loop recovers from invalid tool arguments, refuses truncated tool execution, and preserves complete tool-result history. Paged plan reads and digest-checked partial revisions keep edits small and retain approval, progress, and undo safeguards.

Assistant replies now render themed Markdown. Empty reply bubbles and the three standalone insight cards are removed. Android 1.1.2+23 uses the existing release certificate for in-place updates. Live DeepSeek-account testing was not performed; provider behavior was verified using simulated responses.
