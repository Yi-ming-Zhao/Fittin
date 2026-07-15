## 1. Regression Coverage

- [x] 1.1 Add provider tests that reject a stale workout/progression draft while preserving and upgrading a valid legacy draft.
- [x] 1.2 Add repository-race tests for ordered draft saves, conclusion draining, and no post-clear draft resurrection.
- [x] 1.3 Add tests proving sync refresh does not replace a live session and rapid start requests share one load.
- [x] 1.4 Add phone-viewport widget tests for short high-velocity four-way flicks, immediate completion, exactly-once commands, and rapid Home-card taps.

## 2. Coherent Session Identity And Launch

- [x] 2.1 Add a backward-compatible deterministic progression token to active workout sessions and populate it from progression-driving instance state.
- [x] 2.2 Reject stale sessions during restore and conclusion by comparing stable schedule identity, with structural fallback for legacy drafts.
- [x] 2.3 Keep live active-session state independent of background sync refresh and implement single-flight start/resume behavior.
- [x] 2.4 Add an immediate Home-card navigation lock and disable repeated launch while loading.

## 3. Local-First Draft Persistence

- [x] 3.1 Replace fire-and-forget draft saves with an error-contained serialized local write chain.
- [x] 3.2 Close and drain pending draft writes before successful conclusion clears the draft, then reopen and preserve the captured draft if conclusion fails.

## 4. Responsive Card Gestures

- [x] 4.1 Resolve the drag axis and direction from dominant displacement or release velocity, with separate distance and fling thresholds.
- [x] 4.2 Commit next/previous/complete/skip commands to local provider state before decorative animation and prevent duplicate resolution of one displayed card.
- [x] 4.3 Make completion feedback non-blocking so ticker cancellation cannot cancel a recorded set.

## 5. Verification And Delivery

- [x] 5.1 Regenerate Freezed/JSON code, format changed Dart files, and pass targeted provider/widget/gateway tests.
- [x] 5.2 Pass the full Flutter test suite, analyzer, and production Web build.
- [x] 5.3 Validate OpenSpec and run a mobile long-screen interaction smoke check with rapid taps and flicks.
- [x] 5.4 Commit and push the scoped change, then verify GitHub CI.
- [x] 5.5 Preserve existing remote work, fast-forward `/data/zhaoyiming/Fittin` on `241-dhg` to the pushed commit, and verify the backend services and health without an unnecessary client-only restart.
- [ ] 5.6 Publish the production Web bundle to the Alibaba Cloud ECS release root, atomically activate it, and verify the public app and phone-sized interactions.
