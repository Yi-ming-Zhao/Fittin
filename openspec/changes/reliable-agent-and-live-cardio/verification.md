# v1.5.0 implementation and verification record

current_stage_id: v150-ios-component-20261021-2107
current_watch: /tmp/fittin-v150-ios-watch-20261021-2107
current_wakeup_receipt: /tmp/fittin-v150-ios-receipt-20261021-2107

## Release status

Not released. Work is on `codex/reliable-agent-and-live-cardio`, based on
`43acba2` / `1.4.0+27`. Candidate version is now `1.5.0+28`; no tag, production deployment or
`latest.json` update has been performed. This is not a release-candidate signoff.
The task checklist remains authoritative; partially implemented tasks are not
checked off merely because their unit tests pass.

## Verified implementation

- Agent loops no longer stop at the old model/tool/total-duration/output quotas.
  Productive streams retain first-packet/idle/security protections. Truncated
  text continues; incomplete tool arguments are not executed; identical
  no-progress failures pause resumably.
- Context compaction preserves complete tool pairs and structured task state.
  Stream-tail checkpoints avoid serializing the conversation per token.
  State-transition checkpoints now store 50-message pages and only rewrite
  changed pages. Pages/index share one transaction; restoration re-reads the
  index and pages under one transaction. Legacy embedded checkpoints remain
  readable. Failed writes do not advance the page cache; deletion prunes pages.
  Conversation storage now also uses atomic 50-message pages and an index;
  unchanged pages are not re-serialized on streaming updates. The screen reveals
  older messages in 50-message batches above a stable sliver anchor. Opening a
  conversation still hydrates its complete transcript for the runtime; range reads
  are available but cold-open lazy runtime hydration is not claimed.
- Stable message cards, frame-coalesced following and manual-reading protection
  have widget regressions. Unchanged message widgets retain identity when a new
  tail arrives. One consistent status slot covers connecting/generation/tools/
  compaction/resume; its two-line height scales with accessibility text size.
  Whole-app visual signoff is still outstanding.
- Plan stop/resume/restart uses owner/version-checked transactions. Stop preserves
  the draft; restart creates a new instance after load review and cannot silently
  discard an active draft. Native and fake-Web lifecycle regressions pass.
- Day preview uses the execution engine, handles partial/missing training maxes,
  exposes weeks and localized notes, and avoids presenting placeholder weights.
- Plan editing is overview/day/exercise with advanced disclosure, shared draft,
  empty-plan support and validation navigation to the affected exercise. Device
  review removed repeated heading/card nesting; technical movement/tier/TM fields
  are disclosed separately. New Chinese names and sequential D1/D2 labels are
  tested; existing user names are not rewritten.
- Local cardio sessions store measured route segments, pauses and laps separately
  from ordinary sync. Tests cover drift, jumps, gaps, stale fixes, indoor timing,
  auto-pause, restart recovery and current-speed expiry.
- Android location uses a user-started foreground service with the platform
  LocationManager. iOS uses Core Location; Web interrupts on backgrounding.
  These adapters are implemented, not yet field-qualified.
- Outdoor preparation acquires a fresh, accurate foreground-only fix, stops
  acquisition when ready, and requires a separate Start before creating a
  recording or timer. Cancellation, page exit, backgrounding and account changes
  stop preparation. Indoor timers need no location permission. A fix expires
  after 30 seconds; denied permission/timeout leave no false activity record.
- Delayed local checkpoint buffers larger than 500 points are split into bounded
  documents within one transaction, with one idempotent batch revision. An
  injected failure after route writes rolls back every chunk and the session.
- GPX/TCX/FIT imports retain available route segments/laps. Native and real-browser
  tests prove the summary, receipt and local route commit or roll back together.
  Route data is absent from ordinary summary payloads and inaccessible to a
  different local owner. Explicit GPX export and separately confirmed private
  cloud upload/download/delete are implemented. Route chunks have content hashes,
  manifest CAS and authenticated owner-only access; listings include incomplete
  uploads so orphaned cloud data stays deletable. No coordinates enter normal sync.
- Deleted summary IDs remain known through tombstones, so retained local routes
  are not offered as new unsaved recordings. Unfinished-session recovery is
  explicit and resumes paused, without silently starting location collection.
- Data & privacy now links to owner-scoped local routes, including routes whose
  summary was deleted. This read/export/delete entry cannot recreate a summary;
  deletion requires an explicit consequence dialog. Live cached positions older
  than 10 seconds are excluded from both route capture and freshness indicators.
- Recording pause/resume/save controls are pinned above the bottom safe area.
  Four phone sizes, all existing palettes and both languages verify visible,
  hit-testable controls of at least 48 logical pixels. The route review additionally
  passes 320px / 1.8x text with explicit export consent.

## Evidence from this implementation run

- Candidate native suite: 662 passed, 30 opt-in real-provider cases skipped.
  Subsequent scoped changes were checked separately, not by repeating the full
  suite: deleted cloud manifests and touch/wheel scroll-anchor regression.
- Real official DeepSeek `deepseek-v4-flash` multi-step canary passed in 12 seconds
  with the first two requests deliberately limited by a test-only transport.
  The test asserts at least two actual `length` termination events, then completion
  after approval and analysis. Earlier approval/undo canary remains valid. The key
  was supplied via hidden terminal input to the process environment, not a file,
  command line, build define or printed log.
- Full Flutter analysis found only three brace-style infos; scoped fixes removed
  these. Subsequent code changes receive focused analysis before commit.
- Real Web inspection reproduced wheel/trackpad following while reading older
  output. UserScrollNotification handling now covers inputs without dragDetails;
  both wheel and touch follow/read/return-to-latest widget cases passed.
- PR #14 is a draft: https://github.com/Yi-ming-Zhao/Fittin/pull/14 . Initial
  candidate commit `a4b1c6a` passed all CI jobs in run `39610203513`: Flutter,
  Go, Windows, Linux, macOS and unsigned iOS. Later presentation refinements
  remain a separate candidate revision and require its matching CI result.
- The latest presentation refinement passed 53 relevant widget tests, plus the
  long-plan disclosure case, four full-title responsive cases and three offline
  font tests. See `docs/visual-review-v1.5.0.md` for coverage boundaries.
- Public preflight found an expired Fittin TLS certificate. Normal HTTPS
  validation correctly failed. A separate certificate renewal is in progress;
  no certificate verification bypass is used and no application deployment has
  occurred. The 241 production repository is clean at `43acba2` on main.

- Private-route Go tests: four passed in the isolated 241 source checkout;
  authentication, owner isolation, staging visibility, idempotent commit, stale
  deletion, content digest, request size, internal-field rejection and pagination.
  Production was not changed by these tests.
- Native route restore now reuses its own Isar transaction; the explicit
  upload/download/delete regression passed. Real Chrome nested restore confirms
  rollback leaves no chunks or session, and retry restores all 1,001 points.
- Cloud inventory at 320x568 passed a widget test: browsing performs no writes,
  cancelling deletion performs no writes, and explicit confirmation deletes once.
- Native and real Chrome conversation-page tests passed legacy migration, range
  reads, rollback/retry, page shrink and deletion. Agent controller history reopen
  assertions use full-detail reads; stable history expansion preserves the exact
  viewport anchor in the new 120-message widget regression.

- Agent controller/context/responsive suite: 39 tests passed before the final
  message-widget cache change. After cache/status changes all eight responsive
  tests passed, including the unchanged-widget identity assertion.
- Native transport suite: 15 passed. Backend Agent-focused Go tests passed on 241
  in an isolated small-source test directory, without restarting production.
- DeepSeek official `deepseek-v4-flash`: real connection/tool probe and three
  synthetic tasks (`range-7`, `plan-rest`, `approval-undo`) passed. Key was supplied
  only to the test process, not a file or build define. This is a small canary,
  not the full 30-task provider evaluation or a forced-truncation field test.
- Cardio domain/import suite: 16 passed; the current-speed regression then passed
  with the full nine-test cardio domain file.
- Native atomic route import / owner isolation / export round trip: passed.
- Real Chrome IndexedDB suite: seven passed, including v1/v3/v4 additive upgrade,
  blocked upgrade recovery, cross-store rollback and private route import.
- Cardio domain + import persistence + recording/review widgets: 15 passed.
  After sticky-control changes, the affected four viewport matrix tests passed.
- Cardio controller recovery suite: six passed. Cardio hub/editor: two passed.
  Deleted-summary/owner-isolation provider regression: passed.
- After location preparation: all nine controller tests and all five recording/
  review widget tests passed. Native buffered-checkpoint suite: two passed.
- Paged Agent checkpoint and controller suite: 30 passed. Subsequent atomic
  index/page read refinement passed targeted native and real Chrome tests,
  including stale-index refresh, old-format recovery, owner isolation, failed
  transaction retry, partial-page shrink and deletion.
- After removing redundant screen eyebrows and decorative profile subtitles,
  the presentation sweep passed 237 tests and found five outdated presentation
  assertions. The affected plan/nav/PR suite (16) and Agent surface suite (3)
  then passed after asserting the new labels/status semantics. No failing test
  was skipped. This is reused regression evidence, not final candidate signoff.
- Local-route privacy navigation/deletion and cached-live-fix regressions passed.
  The affected profile/recording/route-inventory tests passed after the privacy
  test was corrected to scroll the lazy page before finding its export action.
- Active-session, sync provider/service, startup and auth provider targeted
  business regression suite: 65 passed. Existing logging/synchronization and
  session restoration behavior remains covered alongside the new features.
- Real Web at 390x844 visually confirmed the nested plan editor and collapsed
  per-set controls. A screenshot is retained outside Git; this does not imply
  all routes or all themes have received manual visual signoff.
- Additional real Web review covered the simplified My page (390px), its
  privacy/local-route nested empty state (320px), and English porcelain Body
  (320px). The Body review found truncated decorative empty-state copy and an
  incorrect first-photo hint after one photo; both were corrected. All 13 Body
  widget tests passed, including a new one-photo regression.
- Explicit conversation deletion now removes its incremental stream tail as
  well as paged checkpoints; the targeted controller regression passed.
- Plan preview/lifecycle/load-review: five passed. Editor/error-navigation and
  template-validation tests passed after updating a changed presentation label.
- Changed-Dart-file analysis found two conditional-import type errors in the
  browser-only test and one unused import; these were corrected and the affected
  analysis returned no issues. Other changed files had no reported issues.
- OpenSpec strict validation and the current batch's `git diff --check`: passed.
- Isolated Flutter Web review build: passed. Generated Isar schema IDs must be
  converted only in the isolated Web source copy, never in a native release build.
- Android debug build: passed (388 tasks, 55m52s). The direct Google Maven path
  failed TLS negotiation; a temporary build-local Aliyun Google-Maven mirror
  completed without changing project repositories, system proxy or TLS checks.
  This is not the final signed release or an upgrade test.
- iOS unsigned release build: blocked before app compilation. Xcode rejects
  `generic/platform=iOS`, reporting the iOS 26.5 device platform is not installed,
  despite listing the SDK. CocoaPods installation succeeded. Official component
  installation was authorized by the user and started through official
  `xcodebuild -downloadPlatform iOS -buildVersion 26.5 -architectureVariant arm64`.
  Approximately 12 GiB was free at launch. Download log:
  `/tmp/fittin-v150-ios-component.log`; prior build log:
  `/tmp/fittin-v150-ios-build.log`.
- macOS release build: passed, producing
  `build/macos/Build/Products/Release/fittin_v2.app` (63.3 MB). This is build
  validation, not a notarized public release. Existing scanner/deployment-target
  plugin warnings remain in `/tmp/fittin-v150-macos-build.log`.

## Remaining implementation and external gates

1. Final provider continuation canary and release-level history/confirmation
   stress checks; storage/display paging is implemented and covered above.
2. Online AMap is explicitly deferred for this trial by the user (2026-10-21).
   Keep it disabled; GPS/timers/offline plots remain available. The user confirmed
   the terms checkbox, which was checked, and the Android form was prepared with
   the stable APK certificate SHA-1, but no Key was created and no purchase made.
   Do not describe offline plots as an online map or completed AMap integration.
3. Verify private-route endpoints after deployment. Local/isolated tests pass;
   production has not received the new endpoints yet. Deletion keeps only a
   content-free version tombstone so old approvals cannot delete a new upload.
4. Complete the entire route/dialog/empty/error/theme/locale visual inventory.
   Existing route-coverage manifests are not screenshots or proof of every state.
5. Run the final, once-per-candidate full quality gate and platform builds; verify
   signed Android upgrade and real 60-minute lock-screen outdoor distance recording.
   No attached Android device is currently available. The user explicitly permits
   a downloadable initial release before their own outdoor trial. The release
   must disclose that 60-minute background/known-distance validation is outstanding.
   Simulated routes are only algorithm/UI evidence, not reliability evidence.
6. Only after those gates: recheck the remote version, prepare PR/CI, merge and
   deploy backend/Web with rollback, publish assets and `latest.json` last, then
   synchronize and archive OpenSpec. iOS remains unsigned validation only.

## Next action

Unsigned iOS already passed the initial candidate CI. The authorized local
component download may finish independently; do not block publication on a
duplicate local build when matching final-candidate CI succeeds. Android debug
compilation has passed. Online AMap remains
disabled by user choice. Continue candidate visual/provider/build verification,
then PR and publication; do not archive this incomplete change yet.
