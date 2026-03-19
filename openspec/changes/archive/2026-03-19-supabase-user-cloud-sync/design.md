## Context

Fittin 当前实现是典型的本地优先结构：Flutter + Riverpod + Isar，本地数据通过 `DatabaseRepository` 与 `ProgressRepository` 管理，训练入口和会话状态由 application/provider 层驱动。这个结构非常适合训练记录场景，因为用户在训练过程中不应该因为网络波动而丢失输入。

现有模型也具备良好的云同步基础：
- `PlanTemplate`、`WorkoutLog`、`TrainingState` 等领域模型都可以稳定序列化为 JSON。
- `TemplateCollection`、`InstanceCollection`、`WorkoutLogCollection` 已经把复杂树结构存成 `rawJsonPayload` 或 JSON 字符串，说明 schema 灵活性优先于强关系映射。
- `main.dart` 仍以 Isar 初始化作为 app 启动关键路径，因此云能力应该叠加，而不是取代本地层。

本次变更改为使用 Supabase 作为首个云后端能力层。Supabase Auth 负责登录体系，Postgres + Row Level Security 负责用户业务数据，Supabase Storage 负责进度照片备份。相较于文档型数据库，Supabase 的关系型结构更适合计划、实例、日志与统计之间的后续演进。

## Goals / Non-Goals

**Goals:**
- 为 app 增加 Supabase Auth 账号体系，并支持会话恢复。
- 保持 Isar 作为训练过程中的本地写入入口，避免把训练流程变成“强依赖在线”。
- 把用户拥有的数据同步到 Supabase，并支持多设备恢复。
- 为未来的进度照片云备份、通知、服务器端聚合逻辑预留稳定的数据边界。

**Non-Goals:**
- 不在本次 change 中重做训练引擎公式或计划业务规则。
- 不做多人协作计划、教练共享或实时协同编辑。
- 不做复杂实时合并算法；首版冲突策略以版本和最后更新时间为主。
- 不把所有 UI 偏好都放上云；首版只同步对跨设备体验真正重要的数据。

## Decisions

### 1. Adopt Supabase as a cloud capability layer, not as the primary runtime database
训练相关的所有即时交互仍然先写入 Isar。Supabase 只负责：
- 账号身份
- 云端备份与恢复
- 多设备同步
- 进度照片对象存储

这样做的原因是：
- 训练时需要低延迟和离线可用性；
- 现有 app 已经围绕 Isar 和 repository 构建；
- 直接让页面改为读写远端数据库会破坏当前稳定的本地流程。

### 2. Split data access into local, remote, and sync layers
现有的 `DatabaseRepository` 与 `ProgressRepository` 需要逐步演进为三层职责：

- `local/*`: 只负责 Isar 读写
- `remote/*`: 只负责 Supabase SDK / REST / Storage 交互
- `sync/*`: 负责 push、pull、冲突处理、重试、合并与状态标记

application/provider 层依赖统一仓储接口，而不是直接依赖某个 Supabase client。这样可以避免 UI 和云后端强耦合。

### 3. Use Supabase Auth for account identity and allow local-first anonymous usage before upgrade
首版账号模型采用 Supabase Auth。推荐最少支持：
- Email + password 注册登录
- Session restore
- Sign out

产品层允许未登录时继续本地使用；一旦用户登录，就触发当前设备数据与该用户云端空间的绑定和同步。这样能保留原型阶段低门槛体验，并降低首次进入流失。

### 4. Store user-owned domain data in Postgres tables protected by RLS
采用用户作用域明确的 Supabase 表结构，建议核心表如下：

- `profiles`
- `plans`
- `plan_instances`
- `workout_logs`
- `body_metrics`
- `progress_photos`
- `sync_state`

每张业务表都带 `user_id`，并通过 Row Level Security 保证用户只能访问自己的数据。

这样做的原因是：
- 比文档型数据库更适合未来统计、筛选和聚合；
- 与训练计划、实例、日志之间的关系更自然；
- 更容易扩展后台任务、报表和 SQL 级分析。

### 5. Reuse existing JSON-friendly domain payloads while gradually normalizing Postgres tables
首版云端数据优先复用现有领域模型的 JSON 结构，例如：
- `plans.raw_json` 对应 `PlanTemplate.toJson()`
- `workout_logs.raw_json` 对应 `WorkoutLog.toJson()`
- `plan_instances.current_states_json`、`training_max_profile_json`、`engine_state_json` 延续当前本地结构

这样做可以：
- 降低 Flutter 端 DTO 改造成本；
- 降低本地和云端 schema 偏移风险；
- 让 change 的第一版更适合快速实现与验证。

### 6. Introduce sync metadata to every cloud-eligible local entity
所有参与同步的本地实体新增或补齐以下元数据：
- `ownerUserId`
- `createdAt`
- `updatedAt`
- `deletedAt`
- `version`
- `syncStatus`
- `lastSyncedAt`
- `lastModifiedByDeviceId`

这些字段用于支持：
- 增量拉取
- 软删除传播
- 乐观并发控制
- 冲突判定
- 后台重试

### 7. Use an asynchronous sync queue instead of waiting on Supabase writes in workout flows
训练相关写入必须遵循：
1. 先写 Isar
2. 标记待同步
3. 异步上传到 Supabase
4. 成功后标记已同步

不能让“完成一组”或“结束训练”依赖远端成功返回。尤其 `concludeSession()` 这类核心路径必须仍然优先保证本地完成，再由后台同步服务处理上传。

### 8. Define conflict handling by data type instead of forcing one global rule
首版冲突策略按实体类型区分：

- `workout_logs`: append-only，以 `logId` 去重，默认不覆盖历史。
- `body_metrics`: append-only，以记录 ID 去重。
- `plans`: 使用 `version` + `updatedAt`，首版采用最后写入获胜。
- `plan_instances`: 使用 `version` + `updatedAt`，如果本地与云端同时改动，则标记冲突并优先保留本地待用户处理。
- `progress_photos`: 元数据最后写入获胜，文件对象按路径或哈希去重。

### 9. Store progress photo binaries in Supabase Storage while keeping local paths for offline UX
本地依然保留 `filePath` 供即时展示。云端同步时：
- 上传图片文件到 Supabase Storage
- Postgres 只存 `storage_path`、标签、时间戳、元数据
- 恢复到新设备时可下载缩略图或原图，并重建本地缓存

这避免把图片二进制直接塞进关系型表，同时保留本地优先体验。

### 10. Defer server-side business logic to later Edge Functions milestones
本次 change 不强制引入 Edge Functions，但明确预留以下后续入口：
- 注册后自动创建用户 profile
- 聚合统计周报
- 安全校验和导出
- 推送提醒

首版实现优先依赖客户端同步与 Supabase RLS，避免把 change 范围扩得过大。

## Architecture Outline

```text
presentation/
application/
  auth_provider.dart
  sync_provider.dart
domain/
  models/
  repositories/
data/
  local/
  remote/
  sync/
```

关键运行流：

1. App startup
   - 初始化 Isar
   - 初始化 Supabase
   - 恢复 Auth session
   - 如果已登录，启动 pull sync

2. User writes data
   - 页面通过 provider 调用统一 repository
   - local repository 立刻写 Isar
   - sync service 记录待上传任务

3. Background sync
   - push pending local changes
   - pull remote changes after `lastSyncedAt`
   - 合并、落地、更新 sync metadata

## Supabase Data Shape

### `profiles`

- `id`
- `email`
- `display_name`
- `locale`
- `preferred_unit`
- `created_at`
- `updated_at`

### `plans`

- `id`
- `user_id`
- `name`
- `description`
- `source_plan_id`
- `is_built_in`
- `is_archived`
- `raw_json`
- `created_at`
- `updated_at`
- `deleted_at`
- `version`
- `last_modified_by_device_id`

### `plan_instances`

- `id`
- `user_id`
- `template_id`
- `current_workout_index`
- `current_states_json`
- `training_max_profile_json`
- `engine_state_json`
- `created_at`
- `updated_at`
- `deleted_at`
- `version`
- `last_modified_by_device_id`

### `workout_logs`

- `id`
- `user_id`
- `instance_id`
- `workout_id`
- `completed_at`
- `raw_json`
- `created_at`
- `updated_at`
- `deleted_at`

### `body_metrics`

- `id`
- `user_id`
- `timestamp`
- `weight_kg`
- `body_fat_percent`
- `waist_cm`
- `note`
- `created_at`
- `updated_at`
- `deleted_at`

### `progress_photos`

- `id`
- `user_id`
- `captured_at`
- `label`
- `storage_path`
- `metadata_json`
- `created_at`
- `updated_at`
- `deleted_at`

### `sync_state`

- `user_id`
- `device_id`
- `last_pulled_at`
- `last_pushed_at`
- `updated_at`

Storage path convention:
- `users/{uid}/progress_photos/{photoId}/original.jpg`

## Risks / Trade-offs

- [Supabase introduces schema and migration discipline earlier] → 首版仍以 JSON payload 为主，避免一开始就过度范式化。
- [Cloud sync can make repository boundaries muddy] → 明确拆分 local / remote / sync 目录，避免把 Supabase 调用散落到 providers。
- [Conflict resolution can get complicated quickly] → 首版只对计划和实例做有限冲突处理，日志和指标维持 append-only。
- [Anonymous local data may collide with cloud state on first login] → 首次登录后执行绑定流程，按实体类型进行 merge，而不是直接覆盖。
- [Photo uploads may fail or be slow] → 照片文件上传与元数据保存解耦，上传失败时保留本地文件和待同步状态。

## Migration Plan

1. Add Supabase SDKs and environment configuration for Android/iOS.
2. Introduce auth bootstrap and session state providers.
3. Add sync metadata fields to local collections and migration logic for existing users.
4. Split repositories into local, remote, and sync responsibilities.
5. Implement Supabase table mapping for plans, instances, logs, metrics, and photo metadata.
6. Build sync queue, push/pull orchestration, and retry behavior.
7. Expose account entry points in settings/profile and connect first-login merge flow.
8. Add verification for offline write, relaunch restore, login sync, and multi-device recovery.

## Open Questions

- 首版是否需要匿名本地模式加显式账号注册，还是还要补一层临时匿名 Supabase 身份。
- `ProgressPhoto` 新设备恢复时是否需要自动下载原图，还是先只恢复元数据与按需拉取。
- 计划 fork 与 built-in 模板升级之间是否需要额外的“模板来源版本号”字段，以支持未来平台模板更新。
