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
- `GET /readyz`
- `POST /v1/auth/sign-up`
- `POST /v1/auth/sign-in`
- `GET /v1/auth/session`
- `POST /v1/auth/sign-out`
- `GET /v1/sync/{table}`
- `POST /v1/sync/upsert/{table}`
- `DELETE /v1/sync/{table}/{id}`
- `POST /v1/files/progress-photos`
- `GET /v1/files/progress-photos/{photoId}`

## Migrations

Apply `backend/migrations/*.sql` in lexical order before starting a newer
backend binary. Migration inputs containing real users or password hashes must
come from an encrypted path outside the repository; never commit them.
