## Why

Fittin 当前的云端能力完全依赖 Supabase 本地栈与 `supabase_flutter`。这要求可用的 Docker/Supabase 运行环境，但当前目标服务器没有可用的 Docker 权限，也不再接受继续依赖 Supabase 作为产品后端。

为了让项目继续支持账号、跨设备同步、训练记录恢复与后续服务化演进，后端必须改为项目自实现，并把 Flutter 客户端从 Supabase SDK 和 Supabase 部署约束中解耦。

## What Changes

- Add a self-hosted Go backend runtime with JWT auth, PostgreSQL persistence, and local-disk file storage.
- Replace Supabase-authenticated client flows with first-party backend auth/session APIs.
- Replace direct Supabase table/storage access with project-owned sync and file endpoints.
- Update app bootstrap and public web build configuration from Supabase defines to backend defines.
- Preserve existing local-first sync behavior and existing exported user/data migration path.

## Capabilities

### New Capabilities
- `custom-backend-runtime`

### Modified Capabilities
- `user-account-authentication`
- `user-cloud-sync`
- `web-public-deployment`

## Impact

- Affects startup/bootstrap, auth providers, sync repositories, deployment scripts, and public deployment docs.
- Introduces a new `backend/` Go service and PostgreSQL schema owned by the repo.
- Requires migration of exported users and user-owned workout data out of the previous Supabase contract.
