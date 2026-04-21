## 1. OpenSpec Artifacts

- [x] 1.1 Add proposal and design for replacing Supabase with a custom Go backend.
- [x] 1.2 Add spec deltas covering auth, sync, deployment, and backend runtime.

## 2. Flutter Runtime Cutover

- [x] 2.1 Replace Supabase bootstrap config with backend bootstrap config while keeping provider entrypoints stable enough for the app/tests.
- [x] 2.2 Replace Supabase auth repository implementation with a first-party HTTP auth repository and session token storage.
- [x] 2.3 Replace Supabase remote repository implementation with HTTP sync/file endpoints.
- [x] 2.4 Remove remaining Supabase-specific copy, docs, and deployment assumptions from the Flutter app and test suite.

## 3. Backend Foundation

- [x] 3.1 Add a Go backend module with config loading, route skeleton, JWT auth middleware, and file-upload endpoint shape.
- [x] 3.2 Add initial PostgreSQL schema migration for users and sync-backed entities.
- [x] 3.3 Implement actual PostgreSQL-backed auth, sync upsert/fetch/delete, and imported-password compatibility.

## 4. Migration And Deployment

- [x] 4.1 Update web build/update scripts to inject backend config instead of Supabase config.
- [x] 4.2 Add import tooling that loads existing exported users and app data into the new PostgreSQL schema.
- [x] 4.3 Replace Supabase-based public deployment docs with backend deployment docs.
- [x] 4.4 Expose the backend through a dedicated Cloudflare Tunnel hostname and validate public `/healthz` reachability.
- [x] 4.5 Make the backend root path return a lightweight service JSON response for browser-based public verification.
- [x] 4.6 Fix the local backend stop script so restart flows terminate the compiled `.local/bin/fittin-backend` process and wait for port release.

## 5. Verification

- [x] 5.1 Update and run Flutter tests covering bootstrap, auth, and sync state.
- [x] 5.2 Add Go backend tests for auth/session and protected sync routes.
- [x] 5.3 Validate exported row counts and user counts against the imported target schema.
