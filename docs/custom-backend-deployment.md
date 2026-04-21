# Fittin Custom Backend Deployment

This document describes the self-hosted backend that replaces the previous Supabase runtime.

## Runtime Shape

- Go API process on `127.0.0.1:8081`
- PostgreSQL database reachable through `FITTIN_DATABASE_URL`
- Local disk storage for progress photos
- Caddy and Cloudflare Tunnel exposing the public API

## Required Environment

- `FITTIN_BACKEND_ADDR`
- `FITTIN_DATABASE_URL`
- `FITTIN_JWT_SECRET`
- `FITTIN_FILE_STORAGE_ROOT`

## Flutter Configuration

Use:

```bash
--dart-define=BACKEND_URL=https://api.yimelo.cc
```

Optionally include:

```bash
--dart-define=BACKEND_API_KEY=<optional-api-key>
```

## Notes

- The backend implementation lives under `backend/`.
- Database schema bootstrap lives under `backend/migrations/`.
- Exported migration assets from the old Supabase environment live under `.deploy/supabase_restore/generated/`.
- The import entrypoint is `backend/cmd/fittin-import`.

## Import Existing Exported Data

After the new schema exists in PostgreSQL, import the checked-in export bundle:

```bash
cd backend
go run ./cmd/fittin-import \
  --auth-sql ../.deploy/supabase_restore/generated/30_restore_auth_data.sql \
  --app-sql ../.deploy/supabase_restore/generated/20_restore_public_app_data.sql
```

Expected source counts from the current bundle:

- `auth.users`: 12
- `plans`: 0
- `plan_instances`: 3
- `workout_logs`: 44
- `body_metrics`: 2
- `progress_photos`: 0

The import tool preserves the exported bcrypt password hashes, so existing email/password users can continue signing in without a forced password reset.
