## Why

当前计划编辑界面仍然按单一模板逻辑设计，无法正确表达线性计划与周期计划的差异，也把组类型、单位体系和规则编辑压缩成过于粗糙的控件。结果是用户既难以直观地修改计划，也容易把不适用于某类计划的规则错误地应用到模板里。

## What Changes

- Redesign the in-app plan editor so linear plans and periodized plans are edited through different information architectures.
- Replace the current AMRAP boolean toggle with a structured set-type selector that supports multiple set categories such as `amrap`, `top_set`, `straight_set`, `backoff_set`, and related working-set types.
- Add an in-app markdown-based training guide that explains common set categories and when to use them, with an entry point from the profile/settings area.
- Persist plan metadata that declares whether a template is `linear` or `periodized`, and use that metadata to drive editor navigation and rule availability.
- Restrict rule editing by engine family so periodized templates do not expose linear-only progression controls such as `on_success` or `on_failure`.
- Expand per-exercise load/unit configuration to support `kg`, `lbs`, `bodyweight`, `cable_stack`, and `%1RM`.

## Capabilities

### New Capabilities
- `set-type-guide`: In-app markdown reference for set categories and selection guidance, accessible from the profile/settings surface.

### Modified Capabilities
- `plan-template-editor`: Redesign the editor flow to support engine-aware layout, day-slot editing for periodized plans, richer set types, and per-exercise unit selection.
- `plan-rule-engine`: Constrain editable progression fields by engine family and set category so only valid rule controls appear for a template.
- `local-datastore-schema`: Persist plan scheduling mode, set-type metadata, and richer unit configuration for templates and template-derived editing state.
- `premium-minimal-frontend-redesign`: Apply the premium/minimal design language to the redesigned plan editor instead of rendering it as a generic dark CRUD form.
- `app-language-settings`: Ensure the new in-app set-type guide and editor labels participate in the app’s bilingual surface.

## Impact

- Affects plan editor screens, template editing models, runtime JSON schema parsing, and settings/profile navigation.
- Requires updating seeded and user-authored template serialization to store schedule mode, set types, and unit metadata.
- Introduces a bundled markdown content asset that must be viewable in-app and localized alongside editor UI copy.
