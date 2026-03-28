## Context

当前代码库中的二级页面头部实现不一致。有些页面使用 `AppBar` 并依赖默认返回行为，有些页面使用自定义 header 或 `DashboardPageScaffold`，还有些页面虽然通过 push 打开，但没有稳定、可见的返回入口。这个问题横跨多个 presentation screen，因此需要先统一设计，再进入实现。

## Goals / Non-Goals

**Goals:**
- 为所有通过 navigator push 打开的二级页面提供稳定、可见的返回图标
- 保持 root 页面与 subpage 的导航语义清晰，不在根页面误显示返回入口
- 让返回图标在 premium/minimal 视觉体系下看起来一致，而不是混用系统默认样式和零散自定义样式
- 为关键页面返回行为补充 widget 测试

**Non-Goals:**
- 不重做整个 app shell 导航结构
- 不在这次 change 中引入新的路由库
- 不统一所有 header 的排版细节，只解决返回入口的一致性与可用性

## Decisions

### 1. 用“是否可 pop”作为返回图标的基础判定
对于通用页面，优先基于当前 route 是否可 pop 来决定是否显示返回图标，而不是为每个页面单独维护布尔开关。

Why:
- 与 Flutter Navigator 语义一致
- 可以覆盖大部分 push 打开的二级页面

Alternative considered:
- 为每个页面手写 `showBackButton` 参数。Rejected，因为维护成本更高，且容易漏页面。

### 2. 为自定义 header 页面补一个共享返回入口模式
对于没有直接使用标准 `AppBar` 的页面，统一增加一个共享的 back icon 呈现方式，使其在 `DashboardPageScaffold` 和 premium header 中也能保持一致。

Why:
- 当前问题主要出在自定义页面头部
- 共享模式能减少零散的局部修补

Alternative considered:
- 把所有页面都强制改回系统 `AppBar`。Rejected，因为会破坏现有 premium 页面结构。

### 3. root 页面显式排除返回图标
app shell 的一级页面和初始入口页面不显示可交互的返回图标，避免用户把它理解为可以返回到不存在的上一层。

Why:
- 返回图标必须表达真实导航关系
- 错误的 back affordance 会削弱导航可信度

Alternative considered:
- 统一给所有页面显示返回按钮，再在无法返回时禁用。Rejected，因为视觉上会造成误导。

## Risks / Trade-offs

- [Risk] 某些页面既可能作为 root 出现，也可能作为 pushed subpage 出现。 -> Mitigation: 基于 navigator `canPop` 做运行时判定，并对特殊页面保留局部覆盖空间。
- [Risk] 自定义 header 页面改动后可能导致标题对齐变化。 -> Mitigation: 只增加最小返回入口，不在同一 change 中扩散到整套 header 重排。
- [Risk] macOS 与移动端的点击区域和视觉密度不同。 -> Mitigation: 优先复用现有 IconButton / AppBar 语义，确保桌面和移动端都可点击。

## Migration Plan

1. 盘点当前通过 push 打开的二级页面和已有返回入口页面。
2. 抽取或统一 subpage 返回图标模式。
3. 逐页补齐缺失返回入口，并确认 root 页面不受影响。
4. 增加 widget 测试覆盖返回图标显示与点击返回行为。
5. 若出现布局回归，先回退共享 header 改动，再逐页局部修复。

## Open Questions

- 是否存在少量页面需要“关闭”语义而不是“返回”语义，图标上要不要区别对待？
- 某些全屏沉浸式页面是否需要更弱化的 back affordance，而不是完全复用标准 subpage 头部？
