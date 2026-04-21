# Supabase Migration From Export

This document describes how to use `migration_export.tar.gz` after pulling it from GitHub.

## What The Bundle Contains

The current exported bundle came from a local Supabase CLI stack running on another machine. It includes:

- schema export from the source Postgres instance
- app table data
- auth row inventory and auth-related data in the full dump
- storage bucket metadata

It does **not** include any actual `progress-photos` object payloads because the export reported zero objects.

## Prepare The Bundle

From the repository root:

```bash
tool/prepare_supabase_restore_bundle.sh migration_export.tar.gz
```

This generates:

- `.deploy/supabase_restore/generated/10_repo_migrations.sql`
- `.deploy/supabase_restore/generated/20_restore_public_app_data.sql`
- `.deploy/supabase_restore/generated/30_restore_auth_data.sql`

## Restore Strategy

### If the target is a managed Supabase project

Recommended:

1. Apply the repo-owned migration SQL.
2. Import the public app data.
3. Import auth rows only if you explicitly need to preserve existing users and you have direct database access that allows writes to `auth.*`.

### If the target is another self-hosted Supabase/Postgres instance

You can use the same order, but the auth restore is more likely to work because the environment is closer to the original source stack.

## Current Source Snapshot

The pulled export reported:

- `auth.users`: 12
- `plans`: 0
- `plan_instances`: 3
- `workout_logs`: 44
- `body_metrics`: 2
- `progress_photos`: 0

## Important Limitation

This repository does not contain a standalone backend service. The historical "backend" was a local Supabase stack. If the new host cannot run Supabase or another compatible target, this export can only be prepared, not fully restored.
