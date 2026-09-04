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
- `FITTIN_ACCESS_TOKEN_TTL_MINUTES` default `15`
- `FITTIN_REFRESH_TOKEN_TTL_DAYS` default `180` (rolling on refresh)
- `FITTIN_FILE_STORAGE_ROOT` default `./var/storage`
- `FITTIN_AGENT_UPSTREAM_TIMEOUT_SECONDS` default `120`
- `FITTIN_AGENT_MAX_REQUEST_BYTES` default `524288`
- `FITTIN_AGENT_MAX_RESPONSE_BYTES` default `8388608`
- `FITTIN_AGENT_MAX_CONCURRENT_PER_USER` default `2`
- `FITTIN_AGENT_RATE_LIMIT_PER_MINUTE` default `12` per user and per IP

## Routes

- `GET /healthz`
- `GET /readyz`
- `POST /v1/auth/sign-up`
- `POST /v1/auth/sign-in`
- `POST /v1/auth/refresh`
- `GET /v1/auth/session`
- `POST /v1/auth/sign-out`
- `GET /v1/sync/{table}`
- `POST /v1/sync/upsert/{table}`
- `DELETE /v1/sync/{table}/{id}`
- `POST /v1/files/progress-photos`
- `GET /v1/files/progress-photos/{photoId}`
- `POST /v1/agent/chat-completions` (authenticated, stateless Web relay)

The Agent relay accepts `{providerBaseUrl, apiKey, payload}`. It only connects
to public HTTPS targets, pins validated DNS results, disables redirects and
environment proxies, and never stores or logs model credentials or traffic.

## Migrations

Apply `backend/migrations/*.sql` in lexical order before starting a newer
backend binary. Migration inputs containing real users or password hashes must
come from an encrypted path outside the repository; never commit them.
