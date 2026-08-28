# Verification: fix-agent-plan-editing

## Root causes and reproduction

- Before the change, `malformed tool arguments are repaired within the same run` failed with `AgentRunPhase.failed` instead of completed. Argument decoding was outside the recoverable tool boundary.
- Full built-in-plan confirmation reproduced `type '_$PhaseImpl' is not a subtype of type 'Map<String, dynamic>'` in `_applyPlanRevision`. A shallow in-memory Freezed snapshot was being decoded as JSON. The same test now completes confirmation and undo with the original built-in plan and progress preserved.
- The old loop ignored `finish_reason=length` and the SSE parser treated EOF as success. Tests now ensure cut-off calls never execute and unexpected EOF reports an interruption.
- The screen rendered every assistant message including its empty streaming placeholder. Tests now require direct error presentation with no empty/tool-only bubble or insight cards.

## Focused checks

- Harness: malformed arguments repaired within one run; truncated valid JSON rejected; complete tool results after approval; follow-up history; cancellation; retry; model/tool limits; DeepSeek hidden-reasoning continuation and key redaction.
- Plan tools: paginated built-in reads, two-field compact revision, actual before/after values, digest mismatch, bad paths/values, no-op rejection, add/remove sets, unchanged source, confirmation, preserved active progress and undo.
- Coordinator: existing idempotency, atomic rollback, stale confirmation, progress migration and undo-conflict regressions.
- Protocol/transport/settings: UTF-8 fragmentation, JSON fallback, explicit completion, timeout/cancel, provider errors, DeepSeek tests, and native/Web envelopes. The truncated-ping test now expects `incomplete_response` rather than successful parsing with no tools.
- UI: Markdown semantics/styles/images/link safety at 320/390 px in five palettes; error card with no blank response; keyboard/six-tab layouts; bilingual long content at 390x844, 390x926, 390x568 and 320x568.
- Targeted analyze passed after addressing formatting/lint findings. OpenSpec strict validation passed. Full CI and publication evidence are recorded by the release workflow and local release report.

## Boundaries

No real DeepSeek API Key was supplied. Live provider/account canary is not claimed. Visual QA uses an isolated actual Flutter Web build with the real controller/tools/coordinator and a UTF-8 SSE mock service; it does not access production user data. The production build does not contain this local-only fixture.

## Published release evidence — 2026-08-28

- [PR #9](https://github.com/Yi-ming-Zhao/Fittin/pull/9) merged as `f3b752e252c0e0ae9f7476c9d03c13eb00c50f59`; [PR CI](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/33154287461) and [main CI](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/33154765425) passed, including Flutter, backend and iOS no-codesign jobs.
- [Release workflow](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/33154786214) passed. [v1.1.2](https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.1.2) contains the signed APK/AAB, Web ZIP and checksum manifest.
- Downloaded APK and Web ZIP matched the CI checksums locally and on Alibaba. APK SHA-256: `406f303827e33410f25547de8a4c89277e6bd0be4ee3293aa2c48b4803ec43e5`; signer SHA-256 remains `0c52c1350c14a360c833422967ac33469572e9acb64a33ddaad1a407532d0671`.
- Installed the CI APK over v1.1.1 build 22 without wiping the Android emulator. Build 23 launched successfully and preserved the existing 12-Week Powerbuilding 4-Day plan at Week 1 / Day 1. The Agent configuration empty state rendered correctly. This fixture did not contain a real authenticated account or provider key.
- Compiled Web visual checks covered five themes, Markdown, direct errors, and the real controller's read/repair/preview/confirm/undo path. A code-block font overlap was fixed during QA. Public Web at 390×844 rendered the home and Agent pages without overflow or fatal console errors.
- 241 fast-forwarded to the release source with its existing backend service active. No backend code, database migration, nginx configuration or service restart was required.
- Alibaba Web now points to `releases/20260828T082736Z/web`; the previous `releases/20260828T071110Z/web` remains available for rollback. No old release was deleted.
- Public `/version.json` reports 1.1.2 build 23, `/api/readyz` returns ready, and unauthenticated Agent forwarding returns JSON HTTP 401. JavaScript is gzip-compressed and CanvasKit uses `application/wasm`.
- The first-party APK returned HTTP 200 with the expected 80,689,782-byte size. `/releases/latest.json` was updated last and its public contents match the verified v1.1.2 manifest.

## Reference

[pi agent-core](https://github.com/earendil-works/pi/blob/main/packages/agent/src/agent-loop.ts) informed the model-turn/tool-outcome/terminal-error separation and refusal to execute length-truncated calls. The implementation remains Dart/Riverpod, with Fittin's stricter per-write approval and bounded tool access.
