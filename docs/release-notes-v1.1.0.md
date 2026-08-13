# Fittin v1.1.0

本版本新增完整的应用内 AI Agent，并继续保持训练数据本地优先、写入可审查、可撤销。

## 应用内 Agent

- 底部新增“AI”入口，可用自定义 Base URL、API Key 和模型 ID 连接 OpenAI Chat Completions 兼容服务。
- 支持流式对话、停止、重试、历史会话、训练分析卡片，以及计划、训练记录和身体指标工具。
- 所有写入先展示结构化差异，用户逐次确认后才在本地提交；重复确认幂等，数据已变化时拒绝过期提案。
- 操作历史保留本地前后快照，并支持冲突安全的一键撤销。
- 修订当前训练计划会创建副本并按稳定 ID 迁移当前周次、下一训练日、训练最大值与动作进度。

## 隐私与跨平台

- API Key、对话和 Agent 操作审计不参与 Fittin 云同步；进度照片、账户、认证和应用设置不会暴露给 Agent。
- Android/iOS Key 使用系统安全存储；Web Key 只保存在当前页面内存，关闭页面后清除。
- Web 通过登录保护的无状态转发访问模型服务，包含公网 HTTPS 限制、DNS 固定、SSRF/重定向/代理阻断、限流和大小限制。
- 五套主题均使用现有语义颜色，没有新增青绿或青色；六栏导航针对 320–390px 手机宽度自适应。

## 更新兼容性

- 版本号为 `1.1.0+21`。继续使用稳定 Android 签名，可覆盖安装 v1.0.13 并保留登录、计划、训练记录和身体数据。
- 原生 Isar 与 Web IndexedDB 迁移只新增本机 Agent 存储，不删除或重建既有业务数据。

---

This release adds Fittin's complete in-app AI Agent while keeping structured fitness data local-first, reviewable, and undoable.

## In-app Agent

- Configure an OpenAI Chat Completions compatible Base URL, API key, and model ID under Profile, then use the new AI tab for streaming conversations.
- Analyze plans, workout history, PRs, volume, consistency, muscle load, and body trends through bounded local tools.
- Plan, workout-log, and body-metric writes always produce a structured diff and require explicit confirmation. Stale proposals and conflicting undo operations are rejected.
- Active-plan revisions fork the template and migrate compatible progress by stable IDs.

## Privacy, security, and updates

- Provider keys, conversations, and Agent audit records never enter Fittin cloud sync; progress photos, account data, authentication, and settings are excluded from tools.
- Native keys use system secure storage. Web keys remain only in the current page process and are cleared when the page closes.
- The authenticated Web relay enforces public HTTPS targets, DNS pinning, SSRF and redirect blocking, bounded traffic, streaming flush, and rate limits.
- Version `1.1.0+21` uses the stable Android signer and additive local-store migrations, preserving existing Fittin data during an update from v1.0.13.
