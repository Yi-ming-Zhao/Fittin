## 1. Supabase Bootstrap and Auth

- [x] 1.1 Add Supabase dependencies and environment configuration for Flutter, including app startup initialization.
- [x] 1.2 Implement an auth repository/provider layer that supports sign up, sign in, session restore, and sign out.
- [x] 1.3 Add a profile/settings entry point for account state, sign-in, and sign-out flows.

## 2. Local Schema and Repository Refactor

- [x] 2.1 Extend sync-eligible local collections with ownership, timestamps, versioning, soft-delete, and sync-status metadata.
- [x] 2.2 Split current repository responsibilities into local repositories for plans, instances, workout logs, and progress tracking.
- [x] 2.3 Add local migration coverage so existing single-device users retain their current data after schema changes.

## 3. Supabase Remote Layer

- [x] 3.1 Implement Supabase repositories for user profile, plans, instances, workout logs, and body metrics.
- [x] 3.2 Implement Supabase Storage upload/download handling for progress photo backup metadata and file transfer.
- [x] 3.3 Define and test Supabase row serialization using the existing JSON-friendly domain models.

## 4. Sync Engine

- [x] 4.1 Implement a sync queue that records pending create, update, and delete operations without blocking workout flows.
- [x] 4.2 Run push/pull synchronization on app launch, successful login, foreground resume, and manual retry.
- [x] 4.3 Add entity-specific merge rules for append-only logs/metrics and versioned plans/instances.

## 5. Product Flows

- [x] 5.1 Ensure user-authored plans and active plan selection become user-scoped after login.
- [x] 5.2 Sync completed workout logs and active instance progress without regressing offline training behavior.
- [x] 5.3 Sync body metrics and progress photo metadata while preserving local-first photo viewing.

## 6. Verification

- [x] 6.1 Add unit tests for auth state restoration, Supabase mapping, and sync metadata transitions.
- [x] 6.2 Add repository tests for first-login merge, push/pull reconciliation, and soft-delete propagation.
- [x] 6.3 Add widget or integration coverage for sign-in entry, logout behavior, and cross-device restore flows.
