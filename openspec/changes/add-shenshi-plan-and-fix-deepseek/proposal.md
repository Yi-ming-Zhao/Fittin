## Why

用户希望把提供的五天训练安排加入内置计划，并修复 DeepSeek 配置测试失败。现有 Agent 强制指定测试工具且丢弃推理续接字段，不能完整兼容 DeepSeek 工具对话。

## What Changes

- 新增内置“沈师五分划”：胸、背、腿、肩、手臂五天循环，保留次数、力竭组、动作提示、替代动作和可选腹部安排。
- 既有安装自动补齐新计划，不切换当前计划或重置训练进度。
- 连接测试改用兼容的自动工具选择，并仍以真实完整的 ping 工具返回作为通过依据。
- 兼容 Base URL 和完整 chat/completions 地址；保存并回传 DeepSeek 工具续接所需推理元数据，不显示或云同步该内容。
- 添加最窄回归测试，明确模拟协议复现和真实供应商测试的覆盖边界。

## Capabilities

### New Capabilities
- `shenshi-five-day-program`: 用户提供的五天分化内置训练计划及无破坏性补齐。

### Modified Capabilities
- `in-app-agent-harness`: DeepSeek 兼容的连接测试、地址处理和推理工具对话续接。

## Impact

计划资源、内置种子注册、Agent 协议/模型/控制器/传输层及对应测试。无新依赖；不改变已有训练实例、云同步实体或写入确认权限。本次不自动发布或更改远端服务。
