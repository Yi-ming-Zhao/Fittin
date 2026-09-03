# Fittin v1.2.1

## 手机页面与操作体验

- 首页在 320 像素窄屏、长屏和大字体下会自动切换紧凑布局，并保留纵向滚动兜底，不再截断训练信息。
- 分享二维码、动作深度分析、计划编辑器和 Agent 对话针对窄屏重新排布；键盘弹出时不再重复压缩 Agent 设置页。
- Agent 对话会在用户停留底部时跟随流式输出；用户主动上滑阅读历史时不会被抢走位置，并可一键回到最新消息。
- 分段选择、语言、记录方式、训练槽位和训练操作补齐选中状态说明与至少 44 像素触控区。

## 稳定性与数据安全

- 身体指标按当前账号隔离；退出或切换账号后不会残留上一账号的数据。体重、体脂和腰围分别采用最近一次有效记录。
- 完成训练时，训练日志、下一训练日进度和同步队列在同一事务内提交；重复点击不会生成重复记录。
- 同步请求较晚返回时会再次核对本地版本，不会覆盖刚完成的训练、刚编辑的数据或误删新的同步任务。
- Web 数据库升级被其他标签页占用时会在有限时间内给出可恢复错误；关闭或版本失效后的连接可以重新初始化。
- Agent 的发送、重试、继续和确认后续跑共用单一运行通道，快速连点不会重复调用模型或覆盖对话状态。
- 跨设备冲突会明确显示为保留状态，不再误报“同步完成”。

## 离线视觉一致性

- 五套主题使用随应用打包的 Inter、Instrument Sans、Instrument Serif、Fraunces 和 JetBrains Mono 官方字体。
- 冷启动或离线使用时不再等待在线字体，也不会因为字体替换出现文字跳动或布局变化。

## 更新说明

- 版本 `1.2.1+25`，Android 正式包继续使用现有稳定签名，可直接覆盖安装 v1.2.0，无需卸载。
- IndexedDB 与原生数据结构没有破坏性迁移；已有登录、计划、训练进度、训练记录、身体数据、Agent 会话和配置均保留。
- iOS 随代码交付并执行无签名构建验证；本轮公开发布物仍为 Android 与 Web。

---

Fittin v1.2.1 improves narrow-screen and large-text layouts, bundles all theme fonts for deterministic offline rendering, isolates body data by account, makes workout completion atomic, prevents late sync responses from overwriting newer local edits, and serializes every Agent run command. Existing data and the Android signing identity are preserved.
