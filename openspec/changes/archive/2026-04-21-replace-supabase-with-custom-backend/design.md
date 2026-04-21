## Context

Current Fittin runtime assumes:

- Flutter client uses `supabase_flutter`
- auth/session comes from Supabase Auth
- sync uses direct table access
- progress photo backup uses Supabase Storage
- web deployment injects `SUPABASE_URL` and `SUPABASE_ANON_KEY`

This tightly couples product behavior to a local or hosted Supabase environment. The replacement backend must preserve the product contract, not the Supabase implementation.

## Decisions

### 1. Replace Supabase with one Go API service

The new backend is a single Go binary exposing:

- `POST /v1/auth/sign-up`
- `POST /v1/auth/sign-in`
- `GET /v1/auth/session`
- `POST /v1/auth/sign-out`
- `GET /v1/sync/{table}`
- `POST /v1/sync/upsert/{table}`
- `DELETE /v1/sync/{table}/{id}`
- `POST /v1/files/progress-photos`

### 2. Preserve user ownership in application logic

Supabase RLS is removed. Every authenticated request carries a JWT, and the Go backend resolves the active user and enforces `row.user_id == token.sub`.

### 3. Preserve the current local-first sync shape

The client still:

1. writes locally first
2. enqueues sync work
3. pushes asynchronously
4. pulls cloud state back into local storage

The backend only replaces transport/auth/storage; it does not redefine training-session local-first semantics.

### 4. Use PostgreSQL plus local disk storage

- PostgreSQL stores users, plans, instances, workout logs, body metrics, and progress photo metadata
- Local disk stores uploaded photo binaries
- Progress photo storage paths stay user-scoped

### 5. Keep exported migration data as the source of truth

The restore bundle already checked into `.deploy/supabase_restore/generated/` is the migration input for:

- existing users
- public app data
- auth-related exported data

### 6. Expose the backend through a dedicated Cloudflare Tunnel

Public backend traffic should not share a tunnel connector pool with unrelated services because Cloudflare may distribute requests across connectors from different hosts. The backend therefore uses a dedicated tunnel and public hostname so that:

- `https://api.yimelo.cc` always maps to the Fittin backend origin at `127.0.0.1:8081`
- tunnel restarts and DNS changes do not affect unrelated self-hosted services
- public health checks can verify the real backend process instead of a mixed multi-origin tunnel

### 7. Make the backend root path operationally useful

Operators often validate a fresh tunnel or DNS cutover by opening the bare hostname in a browser. The backend should therefore return a lightweight JSON response on `/` that confirms the service identity and points at `/healthz`, instead of returning a framework-default 404 that looks like routing failure.

### 8. Stop/start scripts must match the real runtime shape

The local backend is sometimes started from `go run`, and sometimes from the compiled binary at `.local/bin/fittin-backend`. Operational scripts must match both shapes and wait for port release on shutdown, otherwise a restart can falsely succeed while the old process still owns `127.0.0.1:8081`.

## Data Shape

The initial backend schema preserves the existing logical row shape for:

- `users`
- `plans`
- `plan_instances`
- `workout_logs`
- `body_metrics`
- `progress_photos`

This minimizes Flutter-side serializer churn and keeps existing sync metadata fields usable.
