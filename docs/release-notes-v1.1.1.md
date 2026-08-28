# Fittin v1.1.1

## 沈师五分划

- 新增系统自带「沈师五分划」，按胸、背、腿、肩、手臂顺序安排五天、24 个动作。
- 保留组数、次数、力竭组、单侧训练、替代动作、递减组和 21 响礼炮说明；腹部训练作为可选附加说明，不增加第六个必做训练日。
- 更新后自动补齐计划，不切换当前计划或重置训练进度。起始负重由用户确认，不自动加重。
- 补充离线中文字形，确保新计划名称和说明正常显示。

## DeepSeek 兼容性

- 连接测试改用自动工具选择，避免部分推理模型拒绝强制指定工具；只有完整有效的测试工具调用才会通过。
- 接受 Base URL 或完整的 `/chat/completions` 地址，避免路径重复拼接。
- 保留并回传 DeepSeek 连续工具调用需要的推理元数据，支持重新打开本机会话后继续对话。该内容不显示在聊天界面、不参与 Fittin 云同步，并继续执行密钥脱敏。
- 本次兼容性通过模拟服务和回归测试验证；未使用真实 DeepSeek Key 进行账号复测。

## 更新说明

- 版本号 `1.1.1+22`，沿用稳定 Android 签名，可覆盖更新 v1.1.0，无需卸载。
- 不删除现有训练记录、身体数据、登录信息或 Agent 配置。Web 端 API Key 仍仅保存在当前页面内存中，刷新后需重新输入。

---

This release adds Shen's Five-Day Split as a built-in plan and improves DeepSeek compatibility.

- Five sessions and 24 exercises preserve the supplied prescriptions. Abdominal work remains optional guidance, not a sixth mandatory day.
- Existing installations receive the plan without changing the active training program or its progress.
- Provider testing uses automatic tool selection and validates a complete ping call. Full Chat Completions URLs are normalized correctly.
- DeepSeek reasoning metadata is retained locally for tool-call continuation, redacted, hidden from the chat UI, and excluded from Fittin cloud sync.
- Compatibility was verified with simulated provider responses; a live DeepSeek-account test was not performed.
- Android `1.1.1+22` retains the stable release signer for an in-place update from v1.1.0.
