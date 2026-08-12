## Context

Fittin is a Flutter mobile/web client backed by a small Go/PostgreSQL service and a directly deployed static web build. Local-first repositories exist twice (SQLite/mobile and browser/web), synchronization is performed through generic table endpoints, and Android updates currently depend on GitHub release metadata. This makes correctness depend on version propagation, authentication context, HTTP/cache behavior, and deploy ordering across several independently cached layers.

The remediation must retain existing local data and installed-app compatibility. The public web client and backend can be deployed independently, while mobile schema/protocol changes must tolerate old clients during rollout.

## Goals / Non-Goals

**Goals:**

- Prevent cross-account media access, unbounded uploads, leaked source-tree data, and misleading authentication/readiness responses.
- Guarantee that concurrent cloud mutations are detected instead of overwritten and that unresolved work remains retryable.
- Keep plan/session navigation and gesture recording responsive under slow, failed, or reordered requests.
- Restore complete progress-photo and import validation paths.
- Make web/mobile releases self-verifying, cache-correct, and rollback-safe.

**Non-Goals:**

- Rewriting public Git history or invalidating production credentials without a separately verified incident window.
- Changing the Android application id, which would create a separate Play/package identity.
- Replacing the existing backend/database stack or redesigning unrelated visual surfaces.

## Decisions

1. **Authenticate ownership only from JWT context.** Media and sync handlers ignore caller ownership fields for authorization, validate UUID identifiers, cap bodies before multipart parsing, validate decoded image data, and store files beneath a server-owned UUID path. This removes confused-deputy and traversal classes at the boundary.

2. **Use optimistic compare-and-set synchronization.** Each queued mutation carries its local version and device id. The server accepts creates, newer versions, and idempotent same-device retries; it returns a structured `409 sync_conflict` for equal/older competing versions. Clients retain the mutation and materialize a conflict rather than clearing the queue. Remote hydration uses a dedicated repository path that preserves the server version.

3. **Serialize local session intent, not network requests.** A recognized gesture immediately advances local card state and appends a durable local mutation. A single command queue preserves order; cloud synchronization happens after persistence and never blocks animation. Failures remain visible and retryable.

4. **Use additive migrations and backward-compatible responses.** Database indexes/session metadata and local sync metadata are additive. Existing endpoint shapes remain readable; new error payloads add machine-readable codes. Old clients can continue syncing but competing equal-version writes are rejected instead of silently winning.

5. **Complete media replication through authenticated bytes.** Remote rows store a stable media id, not another device's local path. On hydration, clients download owner-authorized bytes to app storage and then update their local path. Upload/download errors retain pending state.

6. **Move update discovery to a first-party manifest with GitHub fallback.** The public host serves signed-build metadata and APK links under the same domain. This decouples installed clients from repository visibility while preserving compatibility during migration.

7. **Treat bootstrap files as mutable and content-addressed assets as immutable.** `index.html`, `flutter_bootstrap.js`, `main.dart.js`, service-worker metadata, and version manifests receive no-cache/revalidation headers; hashed assets receive long immutable caching. Deployment stages a release, probes readiness and manifest/assets, then atomically switches the symlink and rolls back on failure.

8. **Keep incident response explicit.** Current-tree exports are removed and ignored in this change. A generated inventory/runbook describes history rewrite, tag/release consequences, credential invalidation, and user password reset so irreversible production actions are not hidden inside normal deployment.

## Risks / Trade-offs

- [Older clients receive 409 conflicts they do not understand] → Keep JSON error bodies backward readable and deploy server after updated clients are available; conflicts preserve data rather than delete it.
- [Clock/cursor pagination misses updates] → Prefer version/id pagination and an overlap window; never delete local data merely because it is absent from a partial pull.
- [Optimistic gestures outpace disk writes] → Serialize commands, disable only while a local transition is being committed, and keep a visible retry state on failure.
- [Photo downloads increase storage/network use] → Fetch only missing ids, cap image sizes, and reuse local cached files.
- [No-cache bootstrap increases small request volume] → Limit no-cache to entrypoints; retain immutable caching for fingerprints and media.
- [Repository history remediation breaks clones/tags] → Execute separately with backups, contributor coordination, and post-rewrite secret scanning.

## Migration Plan

1. Remove generated exports from the current tree, add ignore/secret-scan rules, and create the incident runbook.
2. Apply additive PostgreSQL and local-store migrations; deploy backend compatibility/hardening and verify readiness/auth/media probes.
3. Release web/mobile clients with CAS sync, owner scoping, media hydration, reliable gesture/draft queues, and first-party updater support.
4. Stage the web build, verify manifest/bootstrap/login paths, atomically activate it, and retain the prior release for rollback.
5. Publish Android `v1.0.13`, verify the manifest and real upgrade path, then observe server conflict/error rates.
6. In an approved maintenance window, back up refs, rewrite leaked blobs from all refs, force-push coordinated replacements, invalidate exposed credentials/passwords, and re-run secret/history scans.

Rollback keeps additive schema columns/tables, restores the prior web symlink/backend binary, and leaves queued client mutations untouched for a subsequent retry.

## Open Questions

- Whether repository visibility should become private after the first-party updater has reached the installed base.
- Whether existing leaked user accounts can be forced through password reset immediately or require direct owner notification first.
