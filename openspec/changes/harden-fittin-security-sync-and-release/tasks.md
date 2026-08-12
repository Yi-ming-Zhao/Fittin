## 1. Repository and incident containment

- [x] 1.1 Remove tracked generated database/auth exports and build reports, add durable ignore rules, and verify the current tree contains no known user rows or password hashes
- [x] 1.2 Add automated secret/generated-export checks and an explicit history-rewrite, credential-rotation, and password-reset runbook

## 2. Backend boundary and schema

- [x] 2.1 Add additive PostgreSQL migration(s) for normalized email uniqueness, sync query indexes, and session/sync metadata
- [x] 2.2 Derive upload/download ownership from JWT context; validate ids, sizes and decoded images; use safe paths, permissions, and atomic storage
- [x] 2.3 Implement authenticated progress-photo download and structured JSON errors
- [x] 2.4 Add liveness/readiness database checks and correctly classify credential, conflict, and database errors
- [x] 2.5 Add configurable CORS, auth/write request rate limits, and bounded request bodies
- [x] 2.6 Implement compare-and-set sync writes with idempotent same-device retries and structured conflicts
- [x] 2.7 Add bounded incremental/paginated sync reads and backend authorization/conflict/media/readiness tests

## 3. Client data consistency

- [x] 3.1 Add timeout-safe optional-JSON HTTP handling for all mobile and web remote operations and close owned clients
- [x] 3.2 Preserve pending mutations on transport/server conflict and prevent unresolved conflicts from being pushed or cleared
- [x] 3.3 Add authoritative remote-merge repository methods that preserve versions/timestamps in SQLite and browser stores
- [x] 3.4 Add incremental cursor/overlap metadata without deleting rows omitted from partial pulls
- [x] 3.5 Pass the active owner through edited/imported template persistence on mobile and web
- [x] 3.6 Prevent stale async plan/instance refreshes from overriding the continuation target after session advancement

## 4. Interaction and feature completion

- [x] 4.1 Make gesture recognition velocity/distance based, exactly-once, locally committed, serialized, and independent of cloud latency
- [x] 4.2 Surface active-session draft persistence errors and provide retry semantics without losing the in-memory set state
- [x] 4.3 Add authenticated progress-photo capture/pick, upload, download/cache, listing, and comparison behavior
- [x] 4.4 Bound QR/template encoded and decompressed payloads and validate domain rules before persistence
- [x] 4.5 Await body metric persistence, validate finite/range values, and keep recoverable save errors visible
- [x] 4.6 Normalize authentication inputs, enforce password bounds, and store mobile tokens using secure platform storage

## 5. Release and deployment integrity

- [x] 5.1 Add first-party release manifest support with backward-compatible GitHub fallback and remove unused compiled backend key configuration
- [x] 5.2 Correct Nginx cache/CORS/security/rate-limit policy and make deployment readiness/version/asset checks roll back automatically
- [x] 5.3 Update project metadata and bump the compatible Android/web release to v1.0.13+20

## 6. Verification and publication

- [x] 6.1 Add/adjust Flutter unit/widget/integration and Go tests for the repaired paths; enforce formatting and generated-data checks in CI
- [ ] 6.2 Run formatting, analyze, full Flutter/Go tests, Android release build, and phone-sized web visual/interaction checks
- [ ] 6.3 Commit and push the reviewed changes, synchronize the 241 checkout without overwriting remote WIP, deploy backend/web migrations safely, and verify public login/readiness/version/update endpoints
- [ ] 6.4 Publish the v1.0.13 Android release and verify an installed Android client can discover and download the update
