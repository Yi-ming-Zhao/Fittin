## Why

当前应用里的二级页面和小页面返回交互不一致，有些页面依赖系统默认导航，有些页面没有清晰可见的返回入口。这会让用户在 macOS 和移动端的页面跳转中产生迷失感，也会削弱当前 premium 界面的一致性。

## What Changes

- 为所有通过 push 打开的二级页面补齐统一、可见的返回图标入口
- 统一小页面顶部导航行为，确保用户可以通过标题栏或页面头部明确返回上一层
- 规范哪些页面应显示返回图标，哪些根页面不应显示返回图标
- 为返回图标的可见性与交互补充测试覆盖

## Capabilities

### New Capabilities
- `subpage-back-navigation`: 规范二级页面返回图标的显示规则、交互行为和视觉一致性

### Modified Capabilities
- `premium-minimal-frontend-redesign`: 小页面顶部导航需要遵循统一的 premium 返回入口样式

## Impact

- 影响 `lib/src/presentation/screens/` 下多个二级页面
- 可能需要抽取共享的页面头部 / AppBar 返回控件
- 影响 widget 测试与页面导航测试
