## Context

当前计划编辑器仍以“一个模板 = 一套统一编辑表单”的前提构建，这对 `linear_tm` 和 `periodized_tm` 两类计划都不成立。GZCLP 这类线性计划每周动作结构稳定，主要编辑的是动作、阶段、单位和线性规则；Jacked & Tan 这类周期计划则需要按具体周/天槽位编辑当天处方，且不应暴露 `on_success` / `on_failure` 这类线性推进规则。

现有界面还把 `amrap` 当成布尔开关，无法表达 `top set`、`straight set`、`backoff set` 等不同训练意图；单位体系也只覆盖常规重量，无法表达 `%1RM`、`bodyweight` 或龙门架片数。与此同时，用户缺少一个能在 app 内查看的“组类型说明”入口，导致编辑行为缺乏共识。

## Goals / Non-Goals

**Goals:**
- 让计划编辑器按模板元数据区分线性计划与周期计划的编辑路径。
- 用结构化组类型替代 AMRAP 开关，并把组类型说明以 markdown 形式内置到 app 中。
- 让可编辑的规则字段受 engine family 约束，避免周期计划误用线性推进逻辑。
- 扩展每个动作的负重/单位表达，使编辑模型能覆盖 `kg`、`lbs`、`bodyweight`、`cable_stack`、`%1RM`。
- 让计划编辑器在 premium minimal 体系下更像面向训练的编排界面，而不是通用 CRUD 表单。

**Non-Goals:**
- 不在本次 change 中重写运行时训练引擎的核心公式。
- 不引入联网内容管理；组类型说明文档以本地 markdown 资产提供。
- 不自动把旧模板无损迁移为完整的高语义 set taxonomy；旧数据允许先映射到兼容默认值。

## Decisions

### 1. 用 `scheduleMode` 明确区分线性编辑与周期编辑
模板层新增 `scheduleMode` 元数据，取值至少包括 `linear` 与 `periodized`。编辑器入口先读该字段，再决定信息架构：
- `linear`: 使用单页/单工作流编辑，默认把动作与规则视为跨周复用。
- `periodized`: 先选择周/天槽位，例如 `W1D1`，再进入该日的训练编辑视图。

这样做比从 engine family 推断更稳，因为未来可能存在同属一个 engine family 但编辑视图不同的模板变种。

### 2. 用结构化 `setType` 枚举替代 `amrap` 布尔值
每组改为持有 `setType`，而不是只有 `amrap: true/false`。首批支持：
- `straight_set`
- `top_set`
- `backoff_set`
- `amrap_set`
- `warmup_set`

必要时允许扩展，但 UI 只暴露受控选项，不允许用户输入任意字符串。训练引擎仍可按兼容方式解析旧字段，但编辑器只写新字段。

### 3. 组类型说明以本地 markdown 文档内置
新增 markdown 资产，内容说明每种组类型的定义、典型用途和常见选法。入口放在个人/设置页，原因是：
- 它更像训练术语手册而不是某个模板专属帮助；
- 用户在编辑前后都能独立回看；
- 双语本地化更容易复用现有设置页信息架构。

### 4. 规则编辑面板按 engine family 白名单裁剪
编辑器读取模板的 `engineFamily` 与 `scheduleMode`，只展示该类计划可用的规则字段：
- `linear_tm`: 可编辑 `on_success`、`on_failure`、增重、降重、reset 等线性逻辑。
- `periodized_tm`: 隐藏线性推进规则，只允许编辑固定处方、周次槽位和依赖 TM 的负重公式。

这样比“显示全部字段但在保存时报错”更安全，也更贴近用户心智。

### 5. 单位系统建模为 `loadUnit`
每个动作或组支持 `loadUnit`，至少覆盖：
- `kg`
- `lbs`
- `bodyweight`
- `cable_stack`
- `percent_1rm`

其中：
- `bodyweight` 表示处方以体重相关方式记录；
- `cable_stack` 允许记录龙门架片数或片位；
- `percent_1rm` 表示该组基于用户 `1RM/TM` 百分比求得目标重量。

运行时展示和保存时都要保留单位语义，而不是只保留数值。

### 6. 计划编辑器采用双层导航而不是把整个周期铺开
周期计划编辑采用两层结构：
- 第一层：周/天选择器，例 `W1D1`, `W1D2`
- 第二层：当天的训练结构编辑

这比把整个周期一次性平铺更适合手机，也更符合 Jacked & Tan 这类计划的“日槽位”思维方式。

## Risks / Trade-offs

- [旧模板只有 `amrap` 布尔值] → 保存时映射到 `amrap_set` 或 `straight_set`，并在编辑器内部统一转成新模型。
- [用户可能分不清 `top_set` 与 `straight_set`] → 用内置 markdown 指南解释术语，并在选择器内提供短描述。
- [线性/周期模式与 engine family 未来可能不完全一一对应] → 将 `scheduleMode` 单独持久化，不把 UI 逻辑硬绑定到 engine family。
- [单位系统变复杂] → 保持首批枚举受控，不开放自定义单位字符串。
- [双语 markdown 维护成本上升] → 先以 app 资产维护中英两份文档，并通过统一入口呈现。

## Migration Plan

1. 为模板 schema 增加 `scheduleMode`、`setType`、`loadUnit` 等字段，并提供旧数据兼容默认值。
2. 先实现新的编辑模型与受控控件，再替换旧的 plan editor screen。
3. 为周期计划新增周/天选择导航，为线性计划保留单页编辑流。
4. 引入本地 markdown 文档与设置页入口。
5. 更新保存校验与导出逻辑，确保新元数据被持久化。

## Open Questions

- `bodyweight` 是否需要支持“体重 + 附加载重”这类复合表达，还是首版先只支持纯体重标签。
- `cable_stack` 在不同器械上的片数是否还需要可选备注字段，而不是只记录整数片数。
- `percent_1rm` 在编辑器中默认引用 `1RM` 还是 `training max`，实现时需要与当前引擎字段命名再对齐一次。
