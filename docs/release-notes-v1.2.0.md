# Fittin v1.2.0

## 可以恢复、继续完成任务的 Agent

- 确认、拒绝或发生数据冲突后，决定会返回给模型，Agent 继续处理剩余任务。
- 应用重启后恢复等待确认或中断状态；只有用户点击继续，才会再次调用模型。
- 运行时间线显示读取、确认、提交、中断和完成；确认卡按时间顺序保留，可展开查看完整差异和进度影响。
- 支持运行中补充要求、停止、安全重试和有上限的历史记录。长对话保留原始目标、约束、已确认操作和完整工具配对。

## 训练数据安全

- 身体指标支持明确清空体脂、腰围和备注；省略字段仍保留原值，撤销可恢复为空值。
- 确认和撤销在本机事务内重新核对版本与 SHA-256 摘要，避免同步竞争造成部分写入。
- 训练日志工具只接受可编辑业务字段，不接受账号、同步版本或进度快照。修复删除嵌套训练日志时的转换错误。
- 当前训练存在草稿时不允许迁移活跃计划；切换账号或清除模型配置会取消旧运行。

## 本机偏好与供应商兼容

- 自动记住用户明确表达的器材、频率、时长、单位和动作偏好，最多 50 条；可编辑、删除、清空或关闭。
- 不记忆健康诊断、身体指标原始值、密钥、引述或模型推断。偏好按账号隔离，仅保存在本机。
- 连接测试记录实际观察到的流式、工具调用、推理字段和用量支持；没有测出的能力显示为未知。
- 分开处理首响应、流式空闲和总时长超时。仅在未产生输出、未提交写入时对临时错误做有限重试。
- 最多保留 200 条脱敏诊断事件，可复制导出，不含提示词、工具结果、身体数据或 Key。

## 更新说明

- 版本 `1.2.0+24`，Android 正式包继续使用原有稳定签名，无需卸载。
- IndexedDB 从 v2 加法升级至 v3；原生新增本机运行存储，不清除已有计划、进度、训练记录、身体数据或登录。
- 原生 Key 仍使用系统安全存储；Web Key 仍只保留在当前页面内存中，不进入云同步。
- iOS 随代码交付，本轮公开发行仍为 Android 和 Web。

---

The Agent now resumes multi-step tasks after approval, restores interrupted local runs without automatic model charges, and shows a chronological decision timeline. Atomic version checks, complete mutation previews, safe nullable-field replacement, account isolation, bounded local preferences and metadata-only diagnostics strengthen data safety. Existing training data and Android signing identity are preserved.
