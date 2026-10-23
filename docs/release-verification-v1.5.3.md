# Fittin v1.5.3 验证

current_stage_id: v153-published
current_watch: none
current_wakeup_receipt: none

目标：使用用户提供的 gaode-key.txt，让地图无需输入 Key；Key 不进入源码或安装包。使用单点、需登录的 Fittin 转发，启用前说明位置分享。原始文件已加入忽略并设为 0600。

## 已验证

- 本机真实高德坐标转换及静态图返回 HTTP 200 PNG；241 经新增 Go 处理器、认证和真实供应商路径返回 600×360 PNG（45,582 字节）。只用公开示例坐标。
- 客户端 9 个协议测试与 3 个组件测试通过：无 Key 字段、默认关闭、取消、未登录、账号切换、认证刷新、限额、脱敏和错误降级。
- Go 地图定向测试通过：认证先于供应商、严格字段/大小/坐标、固定目标、重定向拒绝、图片类型、响应限制、取消、Key 文件验证、并发及用户/全局速率。
- 修改的 Dart 文件静态分析通过。Go 代码使用 241 已有 Go 1.24.5 格式化和测试；未覆盖远端正式工作区。
- PR #19 候选 CI 39915342255 全部六项成功：完整 Flutter/Go 测试、IndexedDB 迁移、Windows/macOS/Linux/iOS 无签名构建。分支 push 的旧运行被同分支 PR 运行替代取消，不是代码失败。
- PR 已合并至 632e2be，合并树与 f19c4e7 候选完全相同；取消重复 main CI 39916503659，复用候选结果。v1.5.3 标签已推送，正式资产运行 39916523945。
- 320/390px 浏览器实际组件检查：默认关闭、无 Key 输入、同意、图片、关闭均通过，无 JS 错误；使用真实供应商图片和合成账号/替代传输，不冒充真实用户登录。截图在 /tmp/fittin-v153-ui/。
- Android 覆盖前为 1.5.2+30，首次安装时间 2026-09-05 03:41:31；现有 Week 1 Day 1 训练草稿与计划已作为对照保存。
- 241 的 GitHub SSH 22/443 连接超时，使用 18 KB Git 增量包将干净 main 从 290a4e2 快进到同一合并提交 632e2be；未覆盖工作区，未传输二进制。Go 在 241 本地构建，保留 `.local/bin/fittin-backend.before-v153` 后原子替换并重启。
- Key 为 0600 私密文件，由用户级服务的 90-amap.conf 仅配置文件路径。公开 `/api/readyz` 正常；地图匿名请求 401；公开已部署地图端点使用 60 秒临时部署探针身份、公开示例点返回 600×360 PNG（46,175 字节）和 no-store。未写用户数据、未保存令牌/坐标/图片；这不是实际用户登录验收。

## 正式发布

- 发布运行 39916523945 全部成功。GitHub v1.5.3 包含 APK、AAB、Web、Windows、macOS、Linux、iOS 无签名包及校验和。
- APK 88,971,973 字节，SHA-256 `84f5b3de6c1c3f202f11062b73f9baf056fb6dcb70238feb84bf0201319195b7`；Web ZIP 26,772,843 字节，SHA-256 `d8305721fb011a319e427f0d3416045b5b8c1ed9a47819550a143f61ae2f1d97`。本机和 ECS 各校验一次，均匹配 CI 清单，ZIP 完整性通过。
- APK 稳定签名 SHA-256 `0c52c1350c14a360c833422967ac33469572e9acb64a33ddaad1a407532d0671`。模拟器原地 `install -r` 成功，从 1.5.2+30 到 1.5.3+31，首次安装时间不变；旧计划、Week 1 Day 1、High-Bar Squat 和 Resume 草稿均保留。未卸载或清除数据；模拟器未登录，不声称已验证真实账号会话迁移。
- ECS Web 原子切至 `/var/www/fittin/releases/v1.5.3/web`，保留 v1.5.2 回滚。公开 readyz/version 正常。390×844 浏览器首页与下载页通过，无 JS 错误；下载链接正确。首页未选计划时顶部仍沿用既有两个占位条，本轮未改此既有状态。
- 最后发布第一方 latest.json：1.5.3/build31/上述 APK 哈希。公开 APK HTTP 200，Content-Length 与资产一致。更新前 manifest 保留为 latest.json.before-v1.5.3。
- Android 关于页显示 1.5.3/build31，实际点击检查更新返回 You are up to date；版本发现请求和应用内状态均正常。
- 公开地图端点浏览器 OPTIONS 返回 204，允许本站 Origin、POST、Authorization 和 Content-Type。

## 部署配置

`FITTIN_AMAP_WEB_SERVICE_KEY` 或 `FITTIN_AMAP_WEB_SERVICE_KEY_FILE` 提供凭证，后者适合 0600 私密文件；不将文件内容写进命令参数、日志或记录。端点 `POST /v1/maps/area` 只接受 latitude/longitude/zoom。每用户每分钟 10 次、全局每分钟 30 次、最多 2 并发；地图每次为 600×360，响应上限 2 MiB。

原始轨迹仍默认仅本机，单点转发不等于路线同步。地图授权仍遵循用户确认的个人测试范围，不购买或扩大高德许可。

## 规范核对

- 完整性：4/4 实施任务完成，正式资产和升级验收已完成。
- 正确性：`area_map.go` 对应登录、单点、固定供应商、限额、大小、类型和错误脱敏；`area_map_test.go` 覆盖四个转发场景。客户端和组件测试对应默认关闭、账号切换、无 Key 输入、认证刷新及失败保留离线功能。
- 一致性：实际提交内容与确认文案均为单点经 Fittin 转发，不再声称直连高德。部署文件路径与环境变量两种配置均仅在服务端生效。无数据 schema 变更。
- 规范已同步至 `configured-map-relay` 和 `live-cardio-recording`；两份主规范及 change 均通过 strict 验证。
- 已知边界：Android 真机 60 分钟户外锁屏及距离对照仍由用户试用；地图是按需图片而非实时导航。iOS 仅无签名构建，桌面无商业签名/公证。
- 无阻止归档的问题；已同步主规范并归档到 `openspec/changes/archive/2026-10-23-use-configured-amap-key/`。
