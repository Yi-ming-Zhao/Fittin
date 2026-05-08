## 1. OpenSpec Artifacts

- [x] 1.1 Add proposal and design for cross-device sync hydration repair.
- [x] 1.2 Add spec deltas for user cloud sync and backend ownership conflict behavior.

## 2. Sync Repair

- [x] 2.1 Update native sync to hydrate remote records before claiming and pushing local-only records.
- [x] 2.2 Update web sync to use the same hydrate-first ordering.
- [x] 2.3 Restore a signed-in user's active training instance from hydrated remote instances when no local user-scoped active selection exists.
- [x] 2.4 Generate user-scoped default instance IDs for future signed-in built-in plan activations.

## 3. Backend Error Handling

- [x] 3.1 Convert cross-user sync upsert ownership conflicts into explicit backend conflict errors.

## 4. Verification

- [x] 4.1 Run Dart formatting and targeted Flutter tests for sync, auth, and account surfaces.
- [x] 4.2 Run Go formatting and backend tests.
- [x] 4.3 Confirm the target account has backend records and can hydrate them through the fixed sync path.
