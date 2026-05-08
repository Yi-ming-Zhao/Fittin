## Context

The app stores training data locally first and synchronizes with the project
backend after authentication. Native clients use Isar, while Flutter Web uses a
browser-backed store. Both sync implementations follow the same conceptual
flow: claim local records, push pending queue items, then pull remote rows.

That order is unsafe for an account that already has cloud data. A fresh device
or browser may create local default state before it has hydrated the account's
remote instances/logs. When default plan instances use shared static IDs, a
pending upload can target a record ID that already exists under another backend
user. PostgreSQL correctly prevents the cross-user update, but the previous
`INSERT ... ON CONFLICT ... WHERE user_id = excluded.user_id RETURNING ...`
implementation exposed that case as a generic "no rows in result set" failure.

## Decisions

### 1. Pull before claiming local data

Sync now performs an initial remote pull before local-only records are claimed
for the authenticated user. This gives the local store a chance to learn about
the account's existing cloud records before deciding which local records should
be uploaded.

The sync still performs a final pull after pushing pending records so local
storage converges on the backend-accepted state.

### 2. Recover active instance selection from cloud state

Hydrating a `plan_instances` row is not enough for user-facing screens. The app
also needs a user-scoped active instance selection. When no local active
selection exists for the signed-in user, the merge step chooses the most
recently updated non-deleted remote instance and stores it as the active
instance for that user.

### 3. Scope new default instances by user ID

Built-in plans previously used static default instance IDs. Those IDs are fine
for signed-out local data, but they are not globally safe once synchronized
through a backend table keyed by `id`. Future signed-in activations prefix the
default instance ID with the authenticated user ID, while signed-out local
activations keep the historical local IDs.

### 4. Report ownership conflicts explicitly

The backend keeps user ownership enforcement in the upsert query. When the
conflict target exists but belongs to another user, the query returns no rows.
The server now maps that condition to a domain error and returns `409 Conflict`
with an ownership-conflict message.

## Risks

- Existing accounts may already have static default instance IDs in the backend.
  The pull-first ordering keeps those records readable and avoids forcing a data
  migration.
- Devices with unrelated signed-out local records still keep those records
  recoverable. If they conflict with remote records, the sync metadata marks
  local conflict paths instead of silently deleting data.
