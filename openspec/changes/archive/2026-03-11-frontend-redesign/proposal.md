## Why

当前的应用 UI 仅停留在基础原型阶段，为了在现代应用市场中脱颖而出，Fittin v2 需要一个极具高级感、极致简约且高度打磨的用户界面。在力量训练中，过于拥挤的 UI 会增加用户的认知负担。一个干净、高级的设计，配合和谐的色彩和微妙的动画，不仅能提升用户体验，还能让应用显得更加专业且令人沉浸。

## What Changes

1. **多套和谐主题系统 (Curated Theme System)**：引入多套经过精心挑选的网络优质配色方案（如深邃海洋、极简暗黑、日落暖阳等），允许用户根据个人喜好自由切换。
2. **极简且克制的页面布局 (Minimalist Layout System)**：重构核心页面（如主页、训练中页面），贯彻“如非必要勿增实体”的理念。利用充足的留白 (Whitespace)，避免在一个页面内堆砌过多的元素，确保核心功能的绝对突出。
3. **高级微动画 (Premium Micro-animations)**：在组件交互（如点击、滑动、完成动作时的打勾）以及页面路由转场中，加入简单却细腻高级的过渡动画。不追求复杂炫酷，而追求丝滑流畅的生理上的“爽感”。
4. **统一的设计语言规范 (Unified Design System)**：建立一套统一的版式、圆角、阴影结构，奠定应用“简单且高级”的基础调性。

## Capabilities

### New Capabilities
- `multi-theme-system`: 支持用户自由选择多套预设的高质量配色模板，并实现全局实时主题切换。
- `premium-micro-animations`: 基础动画库设计，包含适用于交互状态（如按钮按下、列表项删除、成功打卡）的高级感微动画。
- `minimalist-layout-system`: 重构前端布局范式，提供一套高留白、低密度、扁平化的页面结构组件（如卡片、导航栏）。

### Modified Capabilities
- `zero-typing-ui`: 改造现有的 `ActiveSessionScreen` 训练中界面，使其在保留滑动修改数据这一核心功能的前提下，大幅简化视觉层级，消除干扰性元素。

## Impact

- 将深度重构现有的 `lib/src/presentation` 表现层代码。
- 需要在 `lib/src/application` 状态层引入 `themeProvider` 用于管理和持久化用户的主题偏好。
- 对现有的数据结构（如 `Instance`）可能需要少量扩张以存储用户的界面偏好设置。
