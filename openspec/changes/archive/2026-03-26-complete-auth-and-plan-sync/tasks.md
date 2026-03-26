## 1. Sync State And Account Experience

- [x] 1.1 Replace the placeholder account sync copy with provider-driven sync status messaging for signed-in users
- [x] 1.2 Extend `sync_provider.dart` to model hydration, active sync, success, and retry-needed states while preventing overlapping sync runs
- [x] 1.3 Trigger authenticated hydration on sign-in and session restore, and clear user-scoped sync state cleanly on sign-out

## 2. End-To-End Entity Synchronization

- [x] 2.1 Audit and complete `SyncService` push coverage for plans, instances, workout logs, body metrics, and progress photos
- [x] 2.2 Add remote pull and local hydration support for progress photo metadata and any missing sync-eligible entities
- [x] 2.3 Normalize remote repository helpers and serializers so all synchronized records round-trip ownership, version, delete, and device metadata consistently

## 3. First-Login Claim And Conflict Handling

- [x] 3.1 Tighten local repository claim flows so anonymous local records are attached to the authenticated user without losing seeded-template behavior
- [x] 3.2 Standardize conflict detection across templates, instances, workout logs, body metrics, and progress photos when local pending changes overlap newer remote versions
- [x] 3.3 Preserve recoverable local state for first-login merge and failed sync retries instead of silently overwriting or dropping user data

## 4. Verification

- [x] 4.1 Add or update tests for sign-in hydration, retry flows, offline queue replay, and first-login merge behavior
- [x] 4.2 Add or update tests for cross-device restore of plans, active instances, workout logs, body metrics, and progress photo metadata
- [x] 4.3 Validate the account screen and lifecycle-triggered sync flow against real signed-in/signed-out states before implementation is marked complete
