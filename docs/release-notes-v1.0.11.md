# Fittin v1.0.11

本版本包含 v1.0.10 的全部主题、页面审查、训练交互与启动数据修复，并根据真实手机网络和视口验收继续优化开屏交接。

## 启动与移动端

- 新增标准移动端 viewport，真实手机不再把页面按 980px 桌面宽度缩小。
- HTML 杠铃开屏会一直保留到 Flutter 真正绘制首帧；读取本地主题如果超过 2 秒，不再阻塞 Flutter 错误与恢复界面。
- Flutter 准备页在 390x926 长屏和 390x568 短屏均保持视觉居中，内容过长时仍可滚动。
- 内置中文字体由 10.5 MB 全量字体优化为 266 KB 应用字形子集；第一方中文界面仍可离线显示，罕见用户输入字符继续使用系统字体回退。
- Web 静态资源提供预压缩文件，`main.dart.js` 与 CanvasKit WASM 通过 nginx gzip 传输，弱网下持续显示开屏而不会闪出错误计划状态。

## 训练与界面

- 卡片训练支持左/右切换下一组与上一组、上滑记录、下滑跳过，并支持快速滑动与本地即时反馈。
- 重量改为点按编辑，修改后会继承到后续组；配片工具显示抽象杠铃和实际杠铃片。
- 五套完整主题覆盖文字、线条、卡片、图表和状态色，继续保证不出现青绿色主题色。
- 今天、身体、计划、分析、训练记录与我的页面已针对长屏和短屏重新审查并修正布局、加载、空白和错误状态。
- 登录恢复、首次同步和训练日预热采用用户作用域隔离，避免主页与训练页出现不同训练日。

## Android 更新

- 已安装 v1.0.6 或更高版本的用户可以直接安装 v1.0.11 覆盖更新，训练数据、主题与设置会保留。
- v1.0.11 使用与近期版本相同的稳定签名；Android versionCode 为 18。

---

This release includes every v1.0.10 theme, screen-audit, workout-interaction, and startup-state fix, followed by a real-device viewport and slow-network startup pass.

## Startup and mobile

- A standard mobile viewport prevents real phones from shrinking a 980px desktop layout.
- The HTML barbell remains until Flutter paints a real first frame. Loading the saved launch theme can no longer block Flutter indefinitely.
- The Flutter readiness screen stays centered at 390x926 and 390x568 and remains scrollable when recovery content grows.
- The bundled Simplified Chinese fallback is reduced from 10.5 MB to a 266 KB app-copy subset, with platform fallback for uncommon user-entered glyphs.
- Precompressed Web assets let nginx serve gzip JavaScript and CanvasKit WASM, while the launch screen safely covers slow downloads.

## Workout and interface

- Card logging uses left/right for next/previous set, up to log, and down to skip, with fast-fling and optimistic local feedback.
- Weight editing is tap-based, carries changes into later sets, and includes a visual plate-loaded barbell.
- Five complete themes cover text, lines, cards, charts, and states without cyan or teal theme colors.
- Today, Body, plans, analytics, workout history, and Profile were audited across tall and short phone layouts and their loading, empty, and error states.
- User-scoped authentication, hydration, and workout prewarming prevent Home and the active workout from exposing different training days.

## Android update

- Users on v1.0.6 or later can install v1.0.11 directly over the existing app while retaining training data, themes, and settings.
- v1.0.11 uses the established stable signer and Android versionCode 18.
