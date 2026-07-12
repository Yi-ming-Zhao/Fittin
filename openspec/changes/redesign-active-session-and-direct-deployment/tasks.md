## 1. Session State And Preference Tests

- [x] 1.1 Add provider tests that reproduce forward weight inheritance, preserve resolved/unrelated sets, and allow a later edit to become the new inherited value.
- [x] 1.2 Add backwards-compatible cancelled-set state plus provider tests for cancellation, navigation, persistence, and progression-safe output.
- [x] 1.3 Add a persisted card-versus-traditional recording preference and tests for default, update, and reload behavior.

## 2. Mobile Workout Logger

- [x] 2.1 Add widget tests for tap-to-edit weight, centered completion, and rendering the selected traditional or card mode.
- [x] 2.2 Implement the mobile-first current-set card stack with live drag transforms, left completion, down cancellation, threshold snap-back, and semantic fallbacks.
- [x] 2.3 Update the traditional logger to use tap-to-edit weight and a centered primary completion action while preserving existing recording controls.
- [x] 2.4 Replace the numeric-only plate area with an abstract mirrored barbell visualization plus accessible plate text.
- [x] 2.5 Add the recording-mode selector and explanatory copy to profile settings in both supported languages.

## 3. Local Quality And Visual Validation

- [x] 3.1 Format changed Dart files and run targeted provider/widget tests for active session and profile settings.
- [x] 3.2 Run Flutter static analysis, the repository CI test entrypoint, Go tests, and a release Web build.
- [x] 3.3 Exercise card gestures and both recording modes at narrow/tall phone viewports, capture screenshots, and iterate until layout, overflow, semantics, and console output are clean.

## 4. Alibaba Cloud Direct Deployment

- [x] 4.1 Inspect `241-dhg`, the ECS nginx/NPS configuration, available DNS control, TLS certificate coverage, and current public endpoints without exposing credentials.
- [x] 4.2 Replace Cloudflare-oriented repository deployment templates/scripts/docs with the Alibaba Cloud nginx/NPS same-origin `/api` flow and add configuration validation.
- [x] 4.3 Build and upload a versioned Web release, configure the 241 backend tunnel and ECS nginx site, activate the preferred or fallback DNS hostname, and validate HTTPS frontend/API behavior.
- [x] 4.4 Disable Fittin's obsolete Cloudflare production path only after direct validation and record safe rollback/revocation guidance without committing secrets.

## 5. Delivery

- [x] 5.1 Review the final diff to exclude unrelated files and all credentials, then commit and push the scoped change.
- [x] 5.2 Monitor GitHub CI to completion, fix any failures, and re-run public mobile visual/function checks on the deployed revision.
