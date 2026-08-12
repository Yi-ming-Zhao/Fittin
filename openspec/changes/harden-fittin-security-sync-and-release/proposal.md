## Why

Fittin currently has a cluster of release-blocking reliability and security defects: production-like user exports are tracked in a public repository, authenticated uploads trust caller-supplied ownership, cloud synchronization can overwrite concurrent edits, and the installed web/mobile clients can remain stale or present inconsistent plan/session state. These defects must be fixed as one compatibility-aware release because the database, backend, local stores, web deployment, and Android updater form one data path.

## What Changes

- Remove tracked production exports and generated credentials from the distributable source tree, prevent recurrence, and document the separate credential-rotation/history-remediation procedure.
- Harden authentication, upload ownership, request sizing, identifier validation, storage permissions, database error classification, health readiness, CORS, and abuse controls.
- Replace blind last-write-wins synchronization with version-aware conflict handling that never uploads unresolved conflicts or loses local edits, while preserving authoritative remote versions during hydration.
- Scope edited/imported plan templates to the signed-in owner and make the active-session/home plan transition deterministic even under slow or reordered network responses.
- Make session-card gestures optimistic, serialized, and independent of request latency; surface durable draft-write failures instead of silently discarding them.
- Complete progress-photo upload/download synchronization and validate bounded QR/template imports and body-metric input.
- Serve a first-party release manifest, correct web cache/security headers, add readiness-aware deploy/rollback verification, and bump the Android/web release.
- Expand automated coverage for authorization, conflicts, offline/error behavior, validation, and release/deployment invariants.

## Capabilities

### New Capabilities

- `secure-media-storage`: Authenticated, owner-scoped, bounded progress-photo storage and retrieval across devices.
- `release-integrity`: First-party update metadata, immutable-artifact rules, readiness gates, and rollback-safe public deployment.

### Modified Capabilities

- `user-account-authentication`: Normalize identities, strengthen credential/session handling, and distinguish invalid credentials from service failures.
- `user-cloud-sync`: Use version-aware compare-and-set semantics, preserve remote versions, retain conflicts, and make synchronization bounded and retryable.
- `local-datastore-schema`: Persist sync metadata, ownership, tombstones, and migration-safe state required by the new protocol.
- `plan-library-switching`: Keep edited/imported plans visible to their signed-in owner and prevent stale active-plan/session navigation.
- `training-log-screen-refactor`: Make gesture decisions immediate, deterministic, and durable without being gated by network latency.
- `body-metrics-tracker`: Validate metric inputs and support reliable cross-device progress photos.
- `peer-to-peer-sharing`: Bound and validate decoded template payloads before persistence.
- `custom-backend-runtime`: Add readiness, authorization, validation, rate limiting, and correct database failure semantics.
- `web-public-deployment`: Prevent stale bootstrap bundles and verify/rollback deployments at the user-visible endpoint.

## Impact

The change affects Flutter mobile and web repositories/controllers/screens, SQLite and browser persistence, Go HTTP handlers and SQL migrations, Nginx and deployment scripts, CI/release workflows, repository hygiene, and the public Android update channel. Existing user data remains compatible; database and local-store migrations are additive. Repository-history rewriting and credential invalidation are operational incident-response steps and are intentionally separated from ordinary code deployment so they can be executed with explicit verification and rollback planning.
