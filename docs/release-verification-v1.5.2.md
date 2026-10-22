# Fittin v1.5.2 发布验证

current_stage_id: v152-published
current_watch: none
current_wakeup_receipt: none

状态：`1.5.2+30` 已发布。GitHub 全平台资产、公开 Web、第一方 Android 下载及更新索引均完成验证。基线 main `639448e`，上一版 `1.5.1+29`。

## 实施验证

- 34 项控制器、平台状态、界面和地图协议定向测试通过；后台位置保存不依赖定时器、前台启动保护、拒绝通知不阻断运动均有回归。
- 320/390×568、390×844、390×926，现有主题、中英文锁定状态组件覆盖；实际 Web 构建的 320/390px 锁定截图检查通过，路径 `/tmp/fittin-v152-ui/`。
- 地图默认无网络、启用分享确认、失败安全降级、坐标转换、重定向拒绝、响应限额和账号取消均测试。真实个人 Key 未提供，不宣称高德真实加载通过。
- 无数据库 schema 或后端变化。未纳入用户已有的未跟踪文件 `0`。
- 修改文件静态分析、OpenSpec 严格校验和仓库卫生检查通过。Android debug APK 编译通过，新增 Kotlin 通道和通知图标经过原生编译；它不作为签名发布物使用。

## 规范核对

3 项新增要求、1 项更新要求均映射到控制器、原生适配和地图/锁定组件，8 个新场景有回归覆盖。无未实现的阻断级功能要求；发布与归档任务仍待实际门禁完成。地图为手动刷新图片，不声称连续导航或真实 Key 已验证。

## 发布门禁

- [x] 候选 CI 全量门禁、四平台构建与 PR 合并。
- [x] 标签构建成功，稳定签名 APK/AAB、Web 及全平台资产齐备。
- [x] 正式 APK/Web 校验；Android 覆盖升级保留数据。
- [x] Android 模拟器后台/锁屏定位与停止采集检查（不代替真机户外）。
- [x] 241 干净工作区快进同步，后端无变化不重启。
- [x] 阿里云 Web 切换、公开首屏、就绪与认证保护检查。
- [x] 第一方下载可用，最后原子更新 Android latest.json。
- [x] 同步规范并归档，补全实际证据。

## 保留限制

真机 60 分钟锁屏户外/距离对照待用户试用。个人地图默认为关闭，尚无真实 Key 验收；iOS 无签名，桌面未商业签名/公证。

## 构建进度与下一步

- [PR #18](https://github.com/Yi-ming-Zhao/Fittin/pull/18) 合并为 `2933d60af16ddfb9f3e0fe6d96cd7e1cbe3eaf94`；候选为 `e7dd5e6cdfd251df29e4ed1ac59236eda3487ede`。
- [候选 CI 39829640329](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/39829640329) 六项实际作业均 success，包括全量 Flutter、浏览器迁移、Go、Windows/macOS/Linux/iOS 无签名；运行聚合状态仍等待 GitHub 收尾时已依据六项实际结果合并。合并树与候选的应用/测试/依赖/构建完全相同；重复 main CI `39831533598` 取消，复用已完成门禁。
- 标签 `v1.5.2` 固定于上述合并提交，[发布运行 39831561640](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/39831561640) 全部成功；[GitHub Release](https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.5.2) 包含 APK、AAB、Web、Windows、Linux、macOS、iOS 无签名包及校验清单。APK 88,988,357 字节，Web ZIP 26,774,419 字节。
- 241 `/data/zhaoyiming/Fittin` 确认工作区干净后快进至 `2933d60`；后端代码未变，服务仍 active，不重启。
- 模拟器升级前版本 1.5.1/build 29、首次安装 `2026-09-05 03:41:31`；原有 12 周力量健美计划、Week 1 / Day 1、High-Bar Squat 入口存在。基线 XML：`/tmp/fittin-v152-before.xml`。
- 正式 APK/Web 本机 SHA-256 与官方清单相符，Web ZIP 完整性通过；阿里云落地后各校验一次亦通过。APK SHA-256 `dd36a97877d80bee5281ddd73835ef8a6d8fed914ac7dbbf62dec80fd6a0a6a3`；Web ZIP `42d0bf8e322521a866fb9c6666d08ac4abad55fa218ad53710b03f604ead6326`。
- APK 签名证书 SHA-256 `0c52c1350c14a360c833422967ac33469572e9acb64a33ddaad1a407532d0671` 与稳定版一致。模拟器 `adb install -r` 成功，版本更新为 1.5.2/build 30，首次安装时间未变；原有计划、周次和动作保留。该模拟器为匿名测试数据，不将它描述为真实账号迁移验收。
- 首次通知权限弹窗使定位准备失效时，页面明确要求重新检查定位；重新定位后可开始，未在弹窗/后台状态偷偷启动定位前台服务。
- Android 正式包实测：模拟器先前台注入合成 GPS，再返回桌面约 20 秒、熄屏约 30 秒。两阶段定位服务 `isForeground=true`，熄屏时 `mWakefulness=Asleep` 且 Geolocator 部分唤醒锁仍持有；返回后计时从 01:03 到 02:03、距离从 0.04 到 0.11 km。合成轨迹包含被过滤/分段的数据，不将该试验作为距离准确率或真机连续性证明。截图与服务状态位于 `/tmp/fittin-v152-background/`。
- 正式包锁定检查：长按数据区域后仍锁定，长按底部按钮恢复操作；结束后进入回顾，定位前台状态关闭、活动 Geolocator 唤醒锁释放，保存返回有氧入口。测试数据只存在匿名模拟器中。UI 自动化在计时刷新的页面无法取得空闲快照时改用截图，未改动应用代码。
- 阿里云当前软链接已切到 `/var/www/fittin/releases/v1.5.2/web`，保留 v1.5.1 回滚目录；`nginx -t` 通过。公开版本为 1.5.2/build 30、`/api/readyz` 就绪、匿名 Agent 转发返回 401，主 JS gzip 与 WASM MIME 正确。
- 公开 390×844 Web 与下载页检查完成，浏览器无未处理异常；截图 `/tmp/fittin-v152-public/`。这是匿名首屏和下载页检查，不代替所有账号/页面的全量回归。
- 第一方 APK HTTP 200，长度 88,988,357 字节；最后原子更新 `/releases/latest.json` 为 1.5.2/build 30，URL/哈希与正式资产一致，响应 no-store。保留 `latest.json.before-v1.5.2`。正式 Android 包的“关于 → 检查更新”成功返回当前已是最新版。
- 发布入口：[Android 下载](https://fittin.hammerscholar.net/releases/v1.5.2/)、[公开 Web](https://fittin.hammerscholar.net/)、[全平台 GitHub Release](https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.5.2)。高德已按个人测试边界接入，控制台已登录但尚无配置好的个人 Web 服务 Key，真实加载待用户完成 Key 后单独验收。
- 规范已同步，归档路径 `openspec/changes/archive/2026-10-23-harden-cardio-background-lock/`。下一步为用户真机试跑及个人地图 Key 验证，不自动扩大授权、不更换既有标签或签名。

## 平台依据

后台服务在前台显式开始，参见 [Android 官方定位前台服务说明](https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start)。iOS 保留已启用的 location background mode 与活动指示，参见 [Apple 官方说明](https://developer.apple.com/documentation/corelocation/handling-location-updates-in-the-background)。

个人用途与额度依据 [高德授权说明](https://lbs.amap.com/faq/advisory/authorization/43168)；地图只使用 [官方静态地图](https://lbs.amap.com/api/webservice/guide/api/staticmaps) 和 [官方坐标转换](https://lbs.amap.com/api/webservice/guide/api/convert)，不抓取或绕过授权。
