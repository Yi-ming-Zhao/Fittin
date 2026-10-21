## Summary

- Continue productive Agent tasks across provider truncation; compact/paginate stored history and preserve streaming reading anchors, including wheel/trackpad input.
- Add non-destructive plan stop/resume/restart, executable day previews and progressive plan editing.
- Add phone GPS cardio recording, private segmented local routes, import/export and explicitly confirmed owner-only cloud route transfers.
- Simplify mobile/deep-screen hierarchy and preserve existing semantic themes.

## Verification so far

- Native Flutter suite: 662 passed; 30 opt-in provider cases skipped, not counted as passes.
- Official DeepSeek v4 Flash: real connection plus two consecutive forced truncations, continuation and approved multi-step completion passed. Earlier analysis/plan/undo canaries also passed.
- Native and Chrome transactional storage checks cover rollback, account isolation, additive migration and paged histories.
- Private-route Go tests cover auth, ownership, pagination, sizes, hashes, idempotency and delete/reupload stale approvals.
- Web visual review found and fixed wheel scrolling that incorrectly followed the streaming tail; touch and wheel regressions pass.

## User-approved trial boundaries

- Online AMap is disabled. GPS, timers and offline route plots remain available; no map license purchased or Key created.
- Android 60-minute outdoor lock-screen and known-distance validation will be performed by the user after downloading the trial. No physical reliability claim is made.
- iOS is unsigned build validation only. Desktop bundles are not commercially signed/notarized.

## Still pending before merge/publication

Finish the recorded visual review and platform CI, verify stable Android signing/in-place upgrade, safely deploy backend/Web with rollback, validate public endpoints, and publish latest.json last. OpenSpec remains unarchived until those tasks are complete.
