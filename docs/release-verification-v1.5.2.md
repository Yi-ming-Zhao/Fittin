# Fittin v1.5.2 发布验证

current_stage_id: v152-candidate
current_watch: none
current_wakeup_receipt: none

状态：准备 `1.5.2+30` 发布候选，尚未上线。基线 main `639448e`，上一版 `1.5.1+29`。

## 实施验证

- 34 项控制器、平台状态、界面和地图协议定向测试通过；后台位置保存不依赖定时器、前台启动保护、拒绝通知不阻断运动均有回归。
- 320/390×568、390×844、390×926，现有主题、中英文锁定状态组件覆盖；实际 Web 构建的 320/390px 锁定截图检查通过，路径 `/tmp/fittin-v152-ui/`。
- 地图默认无网络、启用分享确认、失败安全降级、坐标转换、重定向拒绝、响应限额和账号取消均测试。真实个人 Key 未提供，不宣称高德真实加载通过。
- 无数据库 schema 或后端变化。未纳入用户已有的未跟踪文件 `0`。
- 修改文件静态分析、OpenSpec 严格校验和仓库卫生检查通过。Android debug APK 编译通过，新增 Kotlin 通道和通知图标经过原生编译；它不作为签名发布物使用。

## 规范核对

3 项新增要求、1 项更新要求均映射到控制器、原生适配和地图/锁定组件，8 个新场景有回归覆盖。无未实现的阻断级功能要求；发布与归档任务仍待实际门禁完成。地图为手动刷新图片，不声称连续导航或真实 Key 已验证。

## 发布门禁

- [ ] 候选 CI 全量门禁、四平台构建与 PR 合并。
- [ ] 标签构建成功，稳定签名 APK/AAB、Web 及全平台资产齐备。
- [ ] 正式 APK/Web 校验；Android 覆盖升级保留数据。
- [ ] Android 模拟器后台/锁屏定位与停止采集检查（不代替真机户外）。
- [ ] 241 干净工作区快进同步，后端无变化不重启。
- [ ] 阿里云 Web 切换、公开首屏、就绪与认证保护检查。
- [ ] 第一方下载可用，最后原子更新 Android latest.json。
- [ ] 同步规范并归档，补全实际证据。

## 保留限制

真机 60 分钟锁屏户外/距离对照待用户试用。个人地图默认为关闭，尚无真实 Key 验收；iOS 无签名，桌面未商业签名/公证。

## 平台依据

后台服务在前台显式开始，参见 [Android 官方定位前台服务说明](https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start)。iOS 保留已启用的 location background mode 与活动指示，参见 [Apple 官方说明](https://developer.apple.com/documentation/corelocation/handling-location-updates-in-the-background)。

个人用途与额度依据 [高德授权说明](https://lbs.amap.com/faq/advisory/authorization/43168)；地图只使用 [官方静态地图](https://lbs.amap.com/api/webservice/guide/api/staticmaps) 和 [官方坐标转换](https://lbs.amap.com/api/webservice/guide/api/convert)，不抓取或绕过授权。
