## 1. Agent foundations and persistence

- [x] 1.1 Add Agent domain models, provider configuration storage contract, run limits, and redaction helpers
- [x] 1.2 Add native Isar conversation/action collections and register their schemas without affecting existing records
- [x] 1.3 Upgrade Web IndexedDB additively to v2 with Agent stores and multi-store transaction support
- [x] 1.4 Implement owner-partitioned local conversation and action repositories for native and Web

## 2. Model protocol and orchestration

- [x] 2.1 Implement OpenAI-compatible Chat Completions request/response models and robust JSON/SSE stream parsing
- [x] 2.2 Implement native direct and Web relay model transports with cancellation, bounded errors, and secret redaction
- [x] 2.3 Implement secure provider settings, real forced-tool connection testing, and configuration readiness state
- [x] 2.4 Implement the bounded Agent runner with message persistence, retry/stop, tool-call assembly, and approval pausing

## 3. Local tools and mutations

- [x] 3.1 Implement bounded owner-scoped read tools for plans, active state, workout history, analytics, PRs, and body metrics
- [x] 3.2 Implement validated proposal-only tools for plans, workout logs, and body metrics while excluding photos and settings
- [x] 3.3 Implement version/digest preconditions, idempotent confirmation, atomic action recording, and conflict-safe undo
- [x] 3.4 Implement active-plan fork/migration and explicit latest-log progression effect handling

## 4. Product interface

- [x] 4.1 Add bilingual Agent copy and a themed provider/privacy settings screen under Profile
- [x] 4.2 Add the sixth AI destination and adaptive narrow-phone bottom navigation behavior
- [x] 4.3 Build the Agent conversation screen with configuration empty state, prompts, streaming/tool status, insight and mutation cards, confirmation/rejection, history, undo, and keyboard-safe composition
- [x] 4.4 Verify all five palettes use semantic tokens and no teal/cyan color is introduced

## 5. Web relay and deployment

- [x] 5.1 Add the authenticated stateless Chat Completions relay with public-HTTPS validation, DNS pinning, redirect/proxy blocking, limits, and streaming flush
- [x] 5.2 Add backend tests for authentication, SSRF, redirects, bounds, streaming, disconnects, concurrency/rate limits, and secret-safe errors
- [x] 5.3 Add nginx streaming/rate configuration and production relay contract tests

## 6. Verification and release

- [x] 6.1 Add Agent unit, repository, migration, tool, orchestration, and widget tests including fragmented UTF-8 SSE and stale/duplicate mutations
- [x] 6.2 Run formatting, Flutter analyze/tests, Go tests, Web build, Android release build, iOS no-codesign build, and OpenSpec validation
- [x] 6.3 Perform long-phone Web visual/interaction regression at 390x844, 390x926, 390x568, and 320px and fix defects
- [ ] 6.4 Set version 1.1.0+21, complete change verification/archive, commit, push, pass CI, review, and merge
- [ ] 6.5 Synchronize 241 by fast-forward, build/restart/verify backend, deploy/verify public Web with rollback retained, and run a non-persisted real-provider canary
- [ ] 6.6 Tag and publish v1.1.0, verify signed APK/AAB/Web/checksums, test Android upgrade from v1.0.13, publish first-party latest.json, and verify public update availability
