# Fittin v1.0.10

本次更新重点解决冷启动的数据竞态，并完成一次覆盖主页面、训练流程、计划管理、分析、身体与设置页面的移动端质量审查。

## 新功能

- 新增从 Android 原生/Web 预加载层连续过渡到 Flutter 的主题化杠铃开屏动画；只有账号恢复、首次本地/云端同步和首页数据预热完成后才进入应用，避免空白等待和短暂显示“无法加载计划”。
- 开屏会延续已保存的主题与语言，支持减少动态效果；网络异常时提供“重试”和“继续使用本地数据”。
- 临时网络故障会保留已登录用户的数据作用域；登录或切换账号后，旧页面会立即隐藏并等待该用户的首次同步完成，避免快速点击进入错误训练日。
- 超大训练计划无法装入二维码时，分享页会提供可恢复的复制方案，不再显示空白或灰色二维码。
- 重量工具新增直观的杠铃配片图，并阻止无效重量被误保存为 0。

## 布局与体验

- 系统审查全部主要页面及重要弹窗、加载、空白和错误状态，并针对 390x926 长屏与 390x568 短屏修正布局和触控范围。
- “今天”无活动计划时显示明确的计划选择入口；长屏内容节奏更舒展，短屏仍保持完整可达。
- “身体”加载和错误状态改为一致的卡片层级，并加入重试操作。
- 底部导航、返回按钮、筛选项和主要按钮采用至少 44px 的触控区域，并修复辅助功能标签重复问题。
- 传统训练记录新增“跳过本组”；卡片训练继续支持左右切组、上滑记录、下滑跳过以及快速滑动。
- 训练历史会保留“跳过”状态，编辑重量、次数与 RPE 时加入有效范围校验。
- 主页训练卡与“分享计划”按钮改为独立操作，避免误触和不可点击状态。

## 质量验证

- 全部 5 套主题继续通过对比度与“无青绿色主题色”自动守卫。
- 覆盖中英文、深色/浅色、长屏/短屏、减少动态效果、离线恢复、无计划、激活计划和训练记录流程。
- 生产 Web 构建、Flutter 静态分析及完整确定性测试套件均通过。

## Android 更新

- 已安装 v1.0.6 或更高版本的用户可以直接安装 v1.0.10 覆盖更新，训练数据、主题与设置会保留。
- 如果设备仍停留在 v1.0.5 或更早版本，请先同步或备份训练数据，再卸载旧版并安装新版。

---

This release fixes the cold-start data race and completes a mobile quality audit across the main tabs, workout flows, plan management, analytics, body tracking, and settings.

## What’s new

- A palette-aware barbell launch sequence now spans the Android native/Web preload layer and Flutter startup gate, holding the app shell until account restoration, initial hydration, and home-data prewarming settle without a blank wait or transient “unable to load plan” state.
- The splash preserves the saved theme and language, honors reduced motion, and offers Retry and Continue locally when startup genuinely fails.
- Transient network failures preserve the signed-in data scope, while sign-in and account changes block the previous shell until that user’s initial hydration completes, preventing fast taps from opening a stale workout day.
- Oversized plans now show a recoverable copy-payload fallback instead of a blank or invalid QR code.
- Weight tools now include a visual plate-loaded barbell and reject invalid values instead of applying zero.

## Layout and experience

- All major screens and significant dialogs, loading, empty, and error states were reviewed at 390x926 and 390x568.
- Today now provides a clear plan-selection action when no plan is active; tall screens gain calmer spacing without compromising short-screen reachability.
- Body loading and error states use the same intentional card hierarchy and expose Retry.
- Navigation, back controls, filters, and primary actions use mobile-friendly touch targets, with duplicate accessibility labels removed.
- Traditional workout logging can skip the current set; card logging retains left/right navigation, swipe-up logging, swipe-down skipping, and fast-fling support.
- Workout history preserves skipped sets and validates edited reps, weight, and RPE.
- The home workout card and Share plan action are independent, preventing accidental or disabled interactions.

## Android update

- Users on v1.0.6 or later can install v1.0.10 directly over the existing app while retaining training data and settings.
- Users on v1.0.5 or earlier should sync or back up their training data before reinstalling.
