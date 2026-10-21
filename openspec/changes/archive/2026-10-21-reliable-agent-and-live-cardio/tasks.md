## 1. Reliable Agent

- [x] 1.1 Replace fixed run/output quotas with cancellation-controlled continuation and no-progress recovery, including regression tests beyond old limits.
- [x] 1.2 Sustain productive native/relay streams without total time cutoffs while retaining first-byte, idle and security protections.
- [x] 1.3 Persist continuation checkpoints and compact complete protocol turns; paginate history outside the streaming hot path.
- [x] 1.4 Stabilize streaming layout, follow/reading anchors and Markdown updates with keyboard/long-output widget regressions.

## 2. Flexible plans

- [x] 2.1 Add atomic owner/version-checked stop/resume/restart preserving history and drafts, with native/Web regressions.
- [x] 2.2 Add concrete week/day previews sharing prescription resolution with execution.
- [x] 2.3 Implement overview/day/exercise editor hierarchy, advanced sections and draft/error navigation tests.

## 3. Live cardio

- [x] 3.1 Implement session/route/lap domain and filtered segmented metrics, including pause/gap/jump tests.
- [x] 3.2 Add owner-scoped local session/route persistence and additive native/Web migration tests.
- [x] 3.3 Implement Android location foreground service, iOS Core Location and foreground-only Web adapters with cancellation/recovery. Physical background reliability remains explicitly unverified for the trial.
- [x] 3.4 Implement preparation/live/pause/lock/finish/review UI, laps and optional auto-pause.
- [x] 3.5 User-approved trial boundary (2026-10-21): leave online AMap disabled and defer key creation/integration until licensing is resolved; GPS/timers/offline route plots remain available. This is a documented deferral, not map integration completion.
- [x] 3.6 Preserve imported routes/laps and add explicit export/private route-sync APIs, access control and deletion tests.

## 4. Whole-app review

- [x] 4.1 Audit every route/dialog/sheet/state through the route coverage inventory and linked tests; remove decorative copy and standardize mobile hierarchy/spacing. Manual browser review is sampled, not an exhaustive screenshot matrix.
- [x] 4.2 Verify all themes/locales at 320px, 390x568/844/926, desktop, large text and keyboard states through shared/component tests and eight-theme browser samples; fix recorded defects. Physical keyboard/permission behavior is not claimed verified.
- [x] 4.3 Run targeted training/history/auth/sync/startup regressions for changed paths.

## 5. Release gates

- [x] 5.1 Verify real provider continuation, approval and undo without leaking credentials.
- [x] 5.2 User-approved trial boundary (2026-10-21): online AMap remains disabled; the user will perform the 60-minute Android outdoor/known-distance trial after download. Release notes must explicitly disclose both limitations. No physical pass is claimed.
- [x] 5.3 Verify full CI/platform builds, additive migrations, Android signing and upgrade from v1.4.0; iOS unsigned only. The signed emulator upgrade retains the anonymous fixture's plan/day/draft entry; authenticated storage migration is covered by focused tests, not claimed as a new real-account upgrade canary.
- [x] 5.4 Bump verified unused version to 1.5.0+28, merge reviewed PR, sync 241 safely and deploy backend/Web with rollback.
- [x] 5.5 Verify public endpoints/Web/update artifacts, publish latest.json last, sync specs and archive with evidence. Six capability specs are synchronized; final release evidence is retained in docs/release-verification-v1.5.0.md.
