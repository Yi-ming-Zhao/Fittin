# Fittin v1.0.13

本版本集中修复训练进度不同步、快速手势漏记、登录和照片隐私等问题，并补全首方更新与部署保护。

## 训练与同步

- 训练完成后立即以本地进度为准，主页与训练记录页不会再出现“主页第 3 天、进入后仍是第 2 天”的回退。
- 上滑记录、下滑跳过、左滑下一组、右滑上一组均先在本机完成，快速滑动不再等待网络响应。
- 点按即可修改重量；修改后的重量自动继承到该动作后续未完成组。
- 草稿保存失败会保留当前组状态并提供重试，不允许在草稿未落盘时误结束训练。
- 多设备同步改为版本比较与冲突保留，分页增量拉取不会误删未返回的数据。
- 登录用户导入或编辑计划时会正确绑定账号，训练记录、PR 和力量健美计划不再因账号作用域错误而消失。

## 体验与外观

- 训练卡片采用实时堆叠与四向手势，并保留可在“我的”页面选择的传统记录方式。
- 杠铃配片显示真实抽象杠铃与每侧配片，不再只有数字。
- 五套完整主题统一覆盖背景、卡片、文字、线条、图表与交互反馈，移除所有青绿色。
- “今天”和“身体”页面重新适配长屏与短屏；新增进度照片拍摄、选择、缓存和并排对比。
- 新增启动加载门控，账号恢复、数据校验完成前不会短暂显示“无法加载计划”。

## 安全与发布

- 登录会话支持服务端撤销，移动端令牌存入系统安全存储；密码和邮箱输入采用统一边界校验。
- 进度照片上传、下载均按 JWT 所属用户鉴权，并限制文件类型、尺寸、路径和权限。
- 后端加入数据库就绪检查、请求限流、受控 CORS、同步冲突响应和结构化 JSON 错误。
- 清理仓库中的数据库/认证导出并加入 CI 阻断检查；历史清理和密码重置步骤记录在安全处置文档中。
- Android 客户端优先读取 Fittin 首方更新清单，GitHub Releases 保留为回退。
- v1.0.13 继续使用稳定 Android 签名，versionCode 为 20，可直接覆盖 v1.0.6 及之后版本并保留本地数据。

---

This release fixes stale workout progression, missed fast gestures, authentication and photo privacy issues, while completing first-party update and deployment safeguards.

## Training and sync

- Workout completion now advances locally before cloud sync, preventing the home screen and active session from showing different days.
- Four-way gestures commit locally: swipe up to log, down to skip, left for the next set, and right for the previous set.
- Weight changes use a tap and propagate through later unresolved sets of the same exercise.
- Draft failures retain the in-memory workout and expose retry instead of silently losing progress.
- Multi-device writes use version-aware conflict retention and paginated incremental pulls.
- Imported and edited plans remain in the signed-in owner's scope.

## Experience, security, and updates

- Five complete non-teal themes, responsive Today and Body layouts, a startup loading gate, barbell plate visuals, and private progress-photo comparison are included.
- Revocable sessions, secure mobile token storage, owner-bound media, bounded requests, readiness checks, CORS, and rate limits harden the service.
- Repository hygiene checks reject generated database/auth exports and password hashes.
- Android checks the first-party Fittin release manifest first and falls back to GitHub Releases.
- v1.0.13 keeps the stable Android signer and uses versionCode 20, so users on v1.0.6 or later can update in place without losing local data.
