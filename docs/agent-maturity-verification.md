# Agent v1.2.0 发布验证

检查日期：2026-08-29。OpenSpec 变更：`mature-fitness-agent`。版本 `1.2.0+24` 已发布，公开 Web、241 后端和 Android `latest.json` 均已更新。规格同步与归档等待用户确认，发布验证与归档状态分别记录。

## 规格核对

| 维度 | 结果 |
| --- | --- |
| 完整性 | 16/16 实施及发布任务完成 |
| 正确性 | 10 条要求、15 个场景已映射至实现与回归测试 |
| 一致性 | 保留 Dart/Riverpod、本机优先、逐次确认；未加入通用执行工具或后台模型调用 |

实现对应关系：

- 事务、空值、完整差异、草稿与并发：`agent_mutation_coordinator.dart`、`agent_atomic_mutation_*`、`agent_tool_input.dart`、`agent_workout_input.dart`；原生和 Web 双连接回归覆盖。
- 事件、检查点、确认续跑、崩溃对账、账号隔离：`agent_runtime.dart`、`agent_harness_controller.dart`、`agent_owner_scope.dart`；控制器重建、拒绝、提交后崩溃、取消和上限测试覆盖。
- 上下文与偏好：`agent_context.dart`、`agent_memory.dart`；完整工具配对、目标保留、引述/健康/密钥排除、关闭和账号隔离测试覆盖。
- 供应商和转发：`agent_model_transport.dart`、`agent_relay.go`；超时、退避、分片、SSRF、断连和脱敏测试覆盖。
- 界面：`agent_run_timeline.dart`、`agent_local_settings.dart`、Agent 两个页面；五套主题、中英文、键盘和窄屏回归覆盖。

## 真实模型验收

官方 Base URL：`https://api.deepseek.com/v1`；用户指定模型：`deepseek-v4-flash`。

- 使用标准输入或临时进程环境传入 Key，只保留在进程内存中，不使用文件或 `dart-define`，不写入仓库或报告。
- 所有训练数据均为测试夹具，不读取生产用户数据。
- 实际连接测试完成流式 `ping` 函数调用。
- 30/30 健身任务通过，包括计划创建/修改、记录纠错/删除、身体指标清空、范围分析、拒绝、冲突、撤销和多步骤续跑。
- 测试断言未确认写入为 0、越权工具调用为 0。
- Go 转发使用本地合成登录会话和真实官方模型，验证 HTTPS/DNS 固定连接、流式 flush 与完整函数调用。
- 后端上线后，另以隔离测试账号经过公开 HTTPS、nginx 和 241 转发调用真实模型；`ping` 工具完成，10 个流分片、9493 字节，首响应 1358 ms、总时长 2246 ms。仅记录状态和耗时，不记录模型内容或凭据。
- 初次真实测试发现并修复：身体指标工具 schema 不接受 null；删除日志时浅层快照无法反序列化。两者都增加了本地回归，随后完整真实矩阵通过。

自动断言证明任务轨迹和数据结果正确，不代表已覆盖所有可能的健身建议质量。

## 本机验证

- Flutter 格式、分析和全量测试通过；全量测试中旧 schema 夹具缺少扩展导入已修复，最终分支和合并后 CI 均全绿。
- 原生旧 schema 加法迁移保留计划、当前训练日、训练日志、身体指标和对话。
- Web v1/v2 加法迁移、两个连接的版本竞争、空值替换、跨仓库回滚及四种计划撤销场景共 8 项通过。
- Go 全量测试通过；真实转发 canary 通过。
- Android APK/AAB release 编译通过。正式包来自 CI 的稳定签名产物，本机未保存签名材料。
- 本机 Xcode 缺少 iOS 平台组件；分支 macOS CI 已完成 iOS 无签名 release 构建。
- Linux CI 发现原生 Isar 关闭后的崩溃，本机最小复现定位到刷新生命周期：Riverpod 2 的调试依赖检查会在 `Ref.invalidate` 时初始化未打开的页面，触发未被等待的内置计划初始化任务。它们在数据库关闭后仍继续写入。现通过统一刷新版本通知已有订阅，避免主动初始化无关页面；无需改动数据库依赖或增加等待延时。另有回归断言验证已订阅页面刷新、未打开页面不启动。
- 扩展真实原生存储检查发现并修复：已软删除的实例仍计入计划使用数，导致计划修订撤销失败。原生与 Web 统一隐藏这些实例，同时保留包括软删除训练记录在内的历史保护；新训练草稿或历史记录会安全阻止撤销。
- 计划撤销、关闭重开、20 次重复冲突、真实写入失败回滚和原数据库回归共 28 项通过。
- 实际 Flutter Web 审查构建通过；模拟服务下完成等待确认、刷新恢复、确认提交、手动继续、分析和 Markdown 输出。
- 已人工检查五套主题，重点尺寸 320×568、390×568、390×844、390×926，补充 1280×900；确认卡、表格、设置、底栏和滚动区域未见溢出。

## 发布与覆盖升级

- [PR #10](https://github.com/Yi-ming-Zhao/Fittin/pull/10) 已自审并合并。发布代码提交为 `29102b8a0ae759a248714c14473a4d96ef860541`。
- [PR CI](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/33198710237) 的 Flutter、Go 和 iOS 无签名构建全部通过；[合并后 CI](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/33199061171) 同样通过。
- [发布工作流](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/33199120209) 成功生成稳定签名 APK、AAB、Web ZIP 和校验文件；[GitHub Release](https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.2.0) 已公开。
- 在独立 Android 36 模拟器中，从稳定签名 v1.0.13（构建 20）使用 `adb install -r` 覆盖至 v1.2.0（构建 24），未卸载、未清空数据。登录及云同步状态保留；计划仍为第 1 周第 2 天；训练日历和 75 kg × 6 次、RPE 7 的记录保留；71.5 kg、18% 体脂、81 cm 腰围及测量历史保留。新增 AI 页正常显示未配置状态。
- APK 大小 82033550 字节，SHA-256 为 `6c48937e68cf8eb0aa2abaaf1a9797393a42e342001fe9599a080a3d569e5bab`；本机下载和阿里云文件均与 CI 一致。签名证书 SHA-256 为 `0c52c1350c14a360c833422967ac33469572e9acb64a33ddaad1a407532d0671`，与旧版一致。
- Web ZIP 大小 25284251 字节，SHA-256 为 `fedce693030f751f7fbb270a6069e34c177a4e206d9e4a24ddad1593b10d80fc`。阿里云直接下载较慢后改为本机直连阿里云传输，未经过 241/NPS。
- 241 仓库通过 `git pull --ff-only` 更新，在服务器本机构建 Go 后端，原子替换二进制并重启用户服务。公开 `/api/readyz` 返回就绪；未登录的 Agent 转发返回 401；已登录的真实模型流式 canary 通过。
- nginx 的 Agent 流式读取超时更新至 310 秒。既有 PID 文件为空，但实际 master 进程正常；配置检查通过并验证 master 身份后以 HUP 平滑重载，未重启 nginx 或改动无关服务。
- 阿里云新 Web 发布目录为 `/var/www/fittin/releases/v1.2.0/web`，原子切换稳定入口。公开 `version.json` 为 1.2.0/24；JavaScript gzip、WASM MIME 和 HTTPS 正常。实际公开首页、Agent 空态和设置页按 390×844 检查通过，原有未完成训练草稿仍保留。
- Android 第一方目录为 `/releases/v1.2.0/`。所有检查通过后最后原子更新 `/releases/latest.json`；公开元数据、APK 大小和校验清单均正确。
- 最终检查发现既有 `/releases/` 总入口缺少首页而返回 403，已补上移动端下载首页，读取 `latest.json` 指向当前版本；具体版本链接继续保持不可变。

## 回滚凭据与边界

- 后端保留 `.local/bin/fittin-backend-before-v1.2.0`；上一版 Web 保留在 `/home/wsf/nginx-fittin/releases/20260828T082736Z/web`，更早的活动发布未清理。
- Android 元数据备份为 `public-releases/latest.before-v1.2.0.json`；本轮未清理旧 APK。
- Android 覆盖升级证据来自隔离模拟器，不代表已经验证所有厂商机型；真实模型评测仅使用明确的测试夹具，不访问用户私人训练数据。
- iOS 只验证无签名构建，本轮没有 App Store 发布。
