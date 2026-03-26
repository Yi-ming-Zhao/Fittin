## Context

The current Flutter app already includes Supabase bootstrap, authentication providers, a local Isar datastore, sync queue models, and a `SyncService` that pushes and pulls several record types. However, the signed-in product flow still feels partial:

- `AccountScreen` shows placeholder copy that cloud sync will arrive later.
- `SyncLifecycleGate` triggers sync runs, but the UI does not expose a reliable sync state model.
- `SyncService` claims local data and synchronizes templates, instances, workout logs, and body metrics, but the end-to-end signed-in story is still incomplete and uneven across entity types.
- Progress photo upload exists, yet the pull/hydration path is not part of the current remote fetch loop.
- First-login claiming currently happens eagerly before push/pull, but the merge contract and conflict visibility need to be made explicit so implementation can safely preserve local work.

This change crosses authentication, local persistence, remote persistence, lifecycle orchestration, and account-facing UI, so a design artifact is warranted before implementation.

## Goals / Non-Goals

**Goals:**
- Make sign-in and session restore transition immediately into a real user-scoped sync lifecycle.
- Ensure plans, active instances, workout logs, body metrics, and progress photo metadata all participate in one consistent sync contract.
- Define a safe first-login claim/merge flow for pre-auth local data.
- Expose sync status to the account surface so users can tell whether hydration, retry, or recovery is in progress.
- Keep the app local-first: training flows must continue to work when offline or signed out.

**Non-Goals:**
- Redesign Supabase schema from scratch if the existing tables can support the requirements with additive changes.
- Implement a fully interactive manual conflict-resolution UI in this change.
- Replace the local-first Isar architecture with a cloud-only architecture.
- Introduce background OS-native sync scheduling beyond the current app lifecycle triggers.

## Decisions

### 1. Keep local-first writes and queue-based sync as the core architecture

The implementation will continue to treat local persistence as the source of immediate UX truth. All mutable entities will write to Isar first, enqueue sync work, and let `SyncService` reconcile with Supabase afterward.

Why:
- The current repositories and sync queue models are already built around local-first persistence.
- This preserves offline usability and avoids blocking training interactions on network availability.

Alternative considered:
- Directly write authenticated changes to Supabase first and mirror them locally afterward. Rejected because it would regress offline flows and require a much broader repository rewrite.

### 2. Introduce an explicit sync state model above `SyncService`

The app will add a sync status model that distinguishes idle, hydrating, syncing, succeeded, and failed/retry-needed states. `SyncLifecycleGate` and manual retry actions will drive this state, and `AccountScreen` will render it instead of static placeholder copy.

Why:
- The current `AsyncValue<void>` controller is enough to represent a single request outcome, but not the richer signed-in states required by the specs.
- Users need to know whether data has actually been hydrated after login or session restoration.

Alternative considered:
- Keep the current controller and infer status only from errors. Rejected because it cannot represent a successful initial hydration versus a no-op versus a retryable failure in a user-visible way.

### 3. Split sync execution into deterministic phases: claim -> push pending -> pull remote -> finalize state

The design will preserve the current broad order, but make it explicit and consistent for all sync-eligible entities:
- Claim anonymous/local-only records for the authenticated user.
- Push pending local records and deletions.
- Pull remote records for all supported entities, including progress photo metadata.
- Mark sync state and surface any conflicts or retry needs.

Why:
- The current service already follows most of this sequence, so clarifying it reduces implementation risk.
- Making the phases explicit simplifies testing and avoids hidden behavior differences between entity types.

Alternative considered:
- Pull first, then claim/push local changes. Rejected because first-login local work could be masked or overwritten before the device has a chance to assert ownership of unsynced local records.

### 4. Handle first-login merge as ownership attachment plus conflict marking, not destructive deduplication

On first authenticated sync for a device, local records without an owner will be claimed for the signed-in user and queued for upload. If a local pending record collides with a newer remote version of the same business record, the local record will remain recoverable and be marked as conflicted instead of being silently dropped.

Why:
- The current data model already contains ownership, version, soft-delete, and sync-status fields.
- This approach satisfies the requirement to preserve local work without committing us to a bespoke merge UI in the same change.

Alternative considered:
- Automatically prefer remote records during first-login reconciliation. Rejected because it risks losing local-only plan edits or workout history that the user expects to keep.

### 5. Complete entity coverage for progress photos and account-facing recovery

The sync implementation will treat progress photos as two-part records: storage object upload/download plus metadata row synchronization. The account screen will expose retry capability and last-known sync outcome for the signed-in user.

Why:
- Upload support already exists, but the cross-device restore story is incomplete until metadata is pulled and local references can be recreated.
- The account surface is already the natural place for sign-in and retry actions.

Alternative considered:
- Leave photo recovery for a later change while syncing everything else now. Rejected because the existing `user-cloud-sync` capability already includes progress photos and the user explicitly asked to fully connect the flow.

## Risks / Trade-offs

- [Risk] Claiming local anonymous records on sign-in could accidentally attach stale seeded or duplicated data to the account. -> Mitigation: limit claiming to sync-eligible user-generated records, preserve built-in template semantics, and add tests around seeded-template visibility.
- [Risk] Pulling remote records after local writes may overwrite newer local intent if version handling is inconsistent across repositories. -> Mitigation: normalize version/conflict checks for every entity type and keep conflicts recoverable rather than destructive.
- [Risk] Progress photo restore may require local file download semantics that differ from metadata-only entities. -> Mitigation: implement metadata hydration first, then materialize or lazily fetch files using a deterministic storage path strategy.
- [Risk] Repeated lifecycle sync triggers may produce duplicate work or noisy UI state. -> Mitigation: gate concurrent sync runs in the controller and coalesce repeated triggers while one run is active.
- [Risk] Surfacing more sync state can reveal backend misconfiguration or partial failures that were previously hidden. -> Mitigation: convert raw errors into user-facing retry guidance while logging technical detail for debugging.

## Migration Plan

1. Add or normalize sync state plumbing in providers and account-facing UI without changing data semantics.
2. Expand `SyncService` and remote repository coverage so every required entity type participates in claim, push, pull, and retry flows.
3. Tighten local repository metadata updates and conflict handling so first-login claiming and subsequent syncs are deterministic.
4. Validate on existing local databases that upgrade/claim behavior preserves records and marks them sync-eligible.
5. Roll back by disabling sync triggers and account sync messaging changes if a release exposes unsafe merge behavior; local data remains preserved because the architecture is local-first.

## Open Questions

- Do progress photo restores in this change need to download image binaries eagerly, or is metadata hydration plus on-demand file fetch sufficient for the initial implementation?
- Are there any Supabase row-level security or storage bucket rules still missing for the entity types already modeled in Dart?
- Should conflict visibility remain account-screen-only for now, or do plan/progress screens also need lightweight indicators in the same implementation pass?
