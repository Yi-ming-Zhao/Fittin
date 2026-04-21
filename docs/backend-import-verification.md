# Backend Import Verification

Date: 2026-04-21

## Scope

This verification confirms the exported Supabase SQL bundle imports into a clean PostgreSQL database with the expected row counts for the custom backend schema.

## Source Bundle Counts

Derived from:

- `.deploy/supabase_restore/generated/30_restore_auth_data.sql`
- `.deploy/supabase_restore/generated/20_restore_public_app_data.sql`

Expected counts:

- `users`: 12
- `plans`: 0
- `plan_instances`: 3
- `workout_logs`: 44
- `body_metrics`: 2
- `progress_photos`: 0

## Verification Database

Temporary database used:

- `fittin_verify_import_20260421_235456`

Steps performed:

1. Applied `backend/migrations/20260421_000001_create_backend_tables.sql`
2. Ran `go run ./cmd/fittin-import` against the clean database
3. Queried the imported target schema row counts

Importer summary:

```text
imported 12 users, 0 plans, 3 instances, 44 workout logs, 2 body metrics, 0 progress photos
```

Imported target counts:

- `users`: 12
- `plans`: 0
- `plan_instances`: 3
- `workout_logs`: 44
- `body_metrics`: 2
- `progress_photos`: 0

## Result

The clean import matches the exported source bundle counts exactly for users and all imported application tables.
