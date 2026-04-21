# Fittin Backend

Self-hosted Go backend intended to replace the previous Supabase runtime.

## Runtime Shape

- Go HTTP API
- PostgreSQL
- Local disk file storage for progress photos

## Environment

- `FITTIN_BACKEND_ADDR` default `:8081`
- `FITTIN_DATABASE_URL` required
- `FITTIN_JWT_SECRET` required
- `FITTIN_FILE_STORAGE_ROOT` default `./var/storage`

## Routes

- `GET /healthz`
- `POST /v1/auth/sign-up`
- `POST /v1/auth/sign-in`
- `GET /v1/auth/session`
- `POST /v1/auth/sign-out`
- `GET /v1/sync/{table}`
- `POST /v1/sync/upsert/{table}`
- `DELETE /v1/sync/{table}/{id}`
- `POST /v1/files/progress-photos`

## Import Existing Data

The repository includes a migration import command that reads the exported SQL
bundle from `.deploy/supabase_restore/generated/` and loads compatible auth and
application rows into the new schema:

```bash
go run ./cmd/fittin-import \
  --auth-sql ../.deploy/supabase_restore/generated/30_restore_auth_data.sql \
  --app-sql ../.deploy/supabase_restore/generated/20_restore_public_app_data.sql
```

The auth import keeps the exported bcrypt hashes from `auth.users`, so existing
users keep their passwords when moving off Supabase.
