# Fittin v1.5.1 发布验证

current_stage_id: none
current_watch: none
current_wakeup_receipt: none

状态：`1.5.1+29` 试用版已于 2026-10-22 发布。GitHub 全平台资产、阿里云 Web、第一方 APK 和 Android 更新索引已上线。

## 改动与规范

`improve-cardio-recording-quality`：6/6 实施任务、3 项要求、7 个场景均有实现和直接回归覆盖。
导入映射到 `cardio_import_service.dart` / `user_content_provider.dart`；定位映射到
`cardio_recording.dart`；展示映射到共享 `cardio_split_list.dart` 与记录/回顾页面。
无未解决的阻断级代码审查问题；不涉及数据库结构、后端协议或认证修改。

实施阶段 41 项定向测试、改动文件静态分析和规范严格校验通过；320/390px、
中英文、深浅主题的合成 Web 页面已检查。详细边界见 `rqrun-cardio-review.md`。
发布候选通过 CI 执行最终格式、全量分析/测试、浏览器迁移与四平台构建；
标签流程执行正式签名 Android 与 Web 构建，不以实施阶段检查替代发布门禁。

## 发布门禁

- [x] 最终候选 CI、四平台原生构建与 PR 合并
- [x] 标签发布成功，APK/AAB 稳定签名及全平台资产齐备
- [x] APK/Web 下载校验，Android 覆盖升级保留现有资料
- [x] 241 干净工作区快进同步；后端无变化则不重启
- [x] 公共 Web 切换与手机首屏、后端就绪和权限检查
- [x] 第一方 APK 校验与下载页可用，最后更新 latest.json

## 保留限制

Android 户外锁屏/已知距离未实测；在线高德关闭；iOS 无签名；桌面未商业签名/公证。
本轮保持原试用边界，正式发布检查不把模拟器、合成路线或构建成功冒充这些验证。

## 构建与同步证据

- [PR #17](https://github.com/Yi-ming-Zhao/Fittin/pull/17) 已合并，标签 `v1.5.1` 固定于 `59f1f33c7e60bf483068ba3257eb7d1e465717f3`。
- 候选 `ba75e0a` 的 [CI 39644217871](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/39644217871) 六项通过：682 个 Flutter 测试通过、30 个可选真实供应商测试跳过；24 个浏览器迁移/事务测试通过；完整分析、Go 测试与四平台构建通过。
- 合并提交与候选的应用、测试、依赖、构建配置完全一致，重复的 main CI `39645528912` 主动取消，复用候选证据。正式发布运行 `39645552245` 负责固定标签产物。
- [正式标签运行 39645552245](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/39645552245) 全部成功。GitHub Release 已于 2026-10-22 01:52:59（UTC+8）发布 Android APK/AAB、Web、Windows、macOS、Linux、iOS 无签名包与校验清单。APK/AAB 在 CI 中验证为稳定签名。
- 241 `/data/zhaoyiming/Fittin` 从干净的 `1bef28d` 快进至 `59f1f33`；后端代码未变，不重启。
- 模拟器保留原匿名资料，从已安装的 v1.4.0 覆盖至 v1.5.0；系统版本 28、首次安装时间仍为 2026-09-05。原 12 周力量健美计划、Week 1 / Day 1 与 High-Bar Squat 草稿仍在，作为新版升级的对照资料。
- 本机 APK/Web SHA-256 与官方清单完全一致，Web ZIP 完整性通过；APK 本机验证签名为 `0c52c1350c14a360c833422967ac33469572e9acb64a33ddaad1a407532d0671`。
- Android `adb install -r` 从 v1.5.0 覆盖至 v1.5.1 成功，系统显示版本 1.5.1/build 29，首次安装时间仍为 `2026-09-05 03:41:31`。升级前后界面均有原计划、Week 1 / Day 1、High-Bar Squat 与 Resume 草稿入口。没有卸载或清空数据；这是匿名模拟器资料，不冒充真实账号登录或户外定位验收。

## 公开入口与回滚

- 阿里云端 APK/Web 再次对照官方清单校验通过，压缩包完整性通过；未重新构建或替换 CI 产物。
- Web 当前链接为 `/var/www/fittin/releases/v1.5.1/web`，旧 `/var/www/fittin/releases/v1.5.0/web` 完整保留。首次切换遇到短暂 EOF，验证脚本自动回滚；兼容旧 curl 的有界重试后重新切换成功。没有关闭 TLS 校验或修改认证。
- 公共 `version.json` 返回 1.5.1/29，`/api/readyz` 就绪；Agent 未登录请求返回 401，主脚本使用 gzip，CanvasKit WASM 类型正确。
- 390×844 实际公开 Web 的未激活计划空态与下载页正常，无浏览器未处理异常。实施阶段的分段页面及主题检查复用，不将此抽查描述为所有页面重新逐一人工检查。截图位于本机 `/tmp/fittin-v151-public/`。
- 第一方 APK 返回 200，长度 88,873,185 字节。最后原子更新 `latest.json` 至 1.5.1/build 29，URL 与官方哈希一致，响应禁止缓存；旧索引保留为 `latest.json.before-v1.5.1`。
- 更新索引切换后，模拟器新版关于页实际点击“Check for updates”，成功显示“You are up to date”，证明应用可读取发布结果；旧版本的新版本比较和下载按钮由 CI 更新测试覆盖，没有把该结果说成在旧版界面实际点击过新版下载。
- 部署无需清理旧版本，无后端重启、数据库迁移或用户资料改写。

入口：[Android 下载](https://fittin.hammerscholar.net/releases/v1.5.1/)、
[公开 Web](https://fittin.hammerscholar.net/)、
[全平台资产](https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.5.1)。

## 正式产物清单

下表为 GitHub Release 公布的尺寸与摘要，本机与阿里云部署端均已校验匹配。

| 产物 | 字节数 | SHA-256 |
|---|---:|---|
| Android APK | 88,873,185 | `2734867260ba8af24bb1c283cf3b88c0404e8445272db60729e302c597029eb8` |
| Web ZIP | 26,763,199 | `d7b15b5b18f219092035254cbbc12c225f12c8e429131390fa358481e777d359` |

全平台资产：[GitHub Release v1.5.1](https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.5.1)。
