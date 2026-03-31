## 1. Session Draft Persistence

- [x] 1.1 Add domain/storage support for persisted active-session drafts in native and web repositories.
- [x] 1.2 Hydrate `ActiveSessionNotifier` from saved drafts and persist draft changes on session mutations.
- [x] 1.3 Clear or invalidate saved drafts on successful conclusion, active-instance replacement, and stale-draft mismatch cases.

## 2. Safe Workout Conclusion

- [x] 2.1 Add a confirmation step before the final conclude-workout action commits the session.
- [x] 2.2 Extend workout conclusion so new logs include stable log IDs plus replay metadata snapshots needed for bounded progression rewrite.

## 3. Editable Workout History

- [x] 3.1 Add repository APIs to fetch and update workout logs by stable log ID across Isar and IndexedDB backends.
- [x] 3.2 Add a single-workout history editor from the day-detail flow for editing set data and completion timestamp.
- [x] 3.3 Refresh record-detail and analytics consumers after a workout-log edit saves successfully.

## 4. Progression Rewrite And Verification

- [x] 4.1 Implement latest-relevant-only progression rewrite when an edited log has replay metadata, while leaving older or legacy logs as log-only edits.
- [x] 4.2 Add tests covering refresh resume, conclude confirmation, workout-log update behavior, and bounded progression rewrite on supported logs.
