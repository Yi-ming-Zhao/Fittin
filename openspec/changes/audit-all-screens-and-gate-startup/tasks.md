## 1. Route And State Audit

- [x] 1.1 Inventory every reachable screen, subpage, sheet, dialog, and significant loading, empty, error, and populated state from screen files and navigation call sites.
- [x] 1.2 Record agent evidence at 390x926 and 390x568 across English/Chinese and representative dark/light palettes, including explicit passes and actionable findings.
- [x] 1.3 Classify findings by severity and accept only reproducible layout, hierarchy, contrast, safe-area, touch-target, gesture, localization, or state defects.

## 2. Startup Readiness

- [x] 2.1 Add regression tests that reproduce the restored-auth/initial-hydration race and prove the app shell cannot expose a transient plan failure.
- [x] 2.2 Implement the bounded startup coordinator for signed-in hydration, signed-out local-first readiness, and plan/dashboard prewarming in the resolved owner scope.
- [x] 2.3 Build the localized, palette-aware abstract-barbell startup animation with reduced-motion behavior.
- [x] 2.4 Add themed blocking-failure recovery with Retry and Continue locally actions, and preserve degraded offline readiness when local data is readable.
- [x] 2.5 Separate initial synchronization ownership from later sign-in, sign-out, and app-resume synchronization so startup never duplicates hydration.

## 3. Evidence-Backed Interface Fixes

- [x] 3.1 Replace Today's no-active-plan generic failure with a localized plan-selection state and navigation action; give genuine plan failures Retry.
- [x] 3.2 Refine only the tall Today composition so bounded useful rhythm consumes the confirmed dead zone without altering short-screen scrolling.
- [x] 3.3 Give Body loading/error states the same intentional card hierarchy as its empty state and add a reachable Retry action.
- [x] 3.4 Prevent Profile from representing unresolved or failed authentication as signed out after startup.
- [x] 3.5 Correct confirmed light-theme small-text contrast and strengthen bottom-navigation icon feedback and selected semantics.
- [x] 3.6 Implement any additional P1/P2 audit findings confirmed by the training-flow and secondary-surface agents; record passing surfaces without code churn.

## 4. Automated Verification

- [x] 4.1 Add startup tests for restored user, signed-out user, hydration failure with readable local data, timeout/error recovery, Retry, Continue locally, and reduced motion.
- [x] 4.2 Add or update geometry, semantics, localization, no-plan, and error-state tests for every accepted interface fix.
- [x] 4.3 Run formatting, Flutter analysis, the full deterministic Flutter suite, backend tests, `git diff --check`, and strict OpenSpec validation.

## 5. Production Visual Verification

- [x] 5.1 Build the production web app and inspect the startup handoff plus every inventoried surface at 390x926 and 390x568.
- [x] 5.2 Repeat representative dark/light palettes in English and Chinese, confirm all five palettes through automated guards, and iterate until no accepted defect remains.
- [x] 5.3 Record a final route/state pass matrix, screenshots, console/overflow results, and any intentionally deferred low-severity opinions.

## 6. Release And Deployment

- [x] 6.1 Bump to the next patch/build version and document startup readiness plus audited interface fixes in bilingual release notes.
- [x] 6.2 Commit and push the scoped change, wait for exact-SHA CI, publish signed Android and Web assets, and independently verify version, checksums, and stable signer.
- [x] 6.3 Synchronize 241 and deploy the Web artifact directly to Alibaba Cloud when access is available, retaining rollback metadata and verifying public mobile behavior.
