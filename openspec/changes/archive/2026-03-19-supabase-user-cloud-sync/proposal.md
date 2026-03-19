## Why

Fittin 目前是一个本地优先的训练记录原型，计划模板、训练实例、训练日志和身体指标都只保存在设备上的 Isar 数据库中。这个结构保证了训练时的流畅性，但也带来了几个明显短板：

- 用户无法注册登录，数据只属于当前设备，换机或多端使用时无法恢复。
- 用户编辑过的计划、训练中的实例状态、历史训练记录和身体数据无法跨设备同步。
- 当前 app 无法为未来的照片云备份、提醒推送、账号升级和多设备连续体验建立基础。

基于方向调整，本次 change 选择以 Supabase 作为首个云后端能力层，在保留 Isar 本地优先体验的前提下，为 app 增加账号与云同步能力。

## What Changes

- Add Supabase-based user authentication with support for sign up, sign in, session restore, and sign out.
- Introduce a cloud sync architecture that keeps Isar as the local source for workout interactions while synchronizing user-owned data to Supabase.
- Persist user-owned plans, active training instances, workout logs, and progress-tracking records under the authenticated Supabase user.
- Add a sync queue and metadata model so local writes can be uploaded asynchronously and pulled back on app launch, login, foreground restore, and network recovery.
- Prepare Supabase Storage usage for progress-photo backup while keeping local file paths available for offline rendering.

## Capabilities

### New Capabilities
- `user-account-authentication`: Users can create an account, sign in, restore their session, and sign out.
- `user-cloud-sync`: User-owned plans, active instances, workout logs, body metrics, and progress photo metadata synchronize between Isar and Supabase.

### Modified Capabilities
- `local-datastore-schema`: Local records gain ownership, versioning, soft-delete, and sync-status metadata so they can safely round-trip with Supabase.
- `plan-library-switching`: Active plan and user-authored plan behavior must become user-scoped once an account is connected.
- `body-metrics-tracker`: Metric entries and progress photo metadata become eligible for cloud backup and cross-device restore.

## Impact

- Affects application startup, provider bootstrapping, repository boundaries, and settings/profile flows.
- Requires introducing Supabase Auth, Postgres-backed data access, and Supabase Storage dependencies plus app environment configuration for iOS and Android.
- Requires refactoring current repositories into local, remote, and sync responsibilities without breaking active workout performance.
- Requires new conflict and merge rules, especially for plan edits and active instance state.
