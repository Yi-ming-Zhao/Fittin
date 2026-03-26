## Why

The app can already create accounts and restore sessions, but the signed-in experience still stops short of a true cloud-backed workflow. Users can log in, yet their plans, active training state, workout history, and progress data are not reliably hydrated, merged, and synchronized across devices, which makes account support feel incomplete.

## What Changes

- Complete the authenticated data flow so signing in restores the user's cloud-backed plans, active plan instances, workout logs, body metrics, and progress photos into local storage.
- Define first-login behavior that safely claims or merges pre-existing local data into the authenticated user's dataset without deleting progress.
- Require local repositories, sync queues, and remote persistence to stay aligned for plan edits, active-instance changes, workout completion, and progress tracking updates.
- Update account and sync surfaces so the signed-in state communicates real synchronization status and can recover from sync failures or retries.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `user-account-authentication`: Expand authenticated session behavior so sign-in transitions trigger user-scoped data hydration and expose sync state that matches the actual backend connection status.
- `user-cloud-sync`: Tighten synchronization requirements for plans, active instances, workout logs, body metrics, and progress photos so signed-in users see consistent state across launches and devices.
- `local-datastore-schema`: Require sync-aware ownership, merge, and queue metadata to support first-login claiming, conflict-safe updates, and end-to-end propagation of user data.

## Impact

- Affected code includes Supabase auth/bootstrap, sync lifecycle management, remote serializers/repositories, local Isar repositories, and account/plan/progress presentation flows.
- Affected systems include Supabase Auth, Supabase database/storage tables for user-owned records, and local sync queue processing.
- This change should bring the existing authentication and sync foundations to implementation-ready scope without introducing a separate new product capability.
