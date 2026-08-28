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

## Reference

[pi agent-core](https://github.com/earendil-works/pi/blob/main/packages/agent/src/agent-loop.ts) informed the model-turn/tool-outcome/terminal-error separation and refusal to execute length-truncated calls. The implementation remains Dart/Riverpod, with Fittin's stricter per-write approval and bounded tool access.
