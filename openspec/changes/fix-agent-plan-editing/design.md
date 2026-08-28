## Context

The current Dart harness ignores finish reasons and decodes tool arguments outside the recoverable tool boundary. Approval returns mid-batch, which leaves provider-invalid history. Full-plan replacement is expensive (the 12-week powerbuilding source is 282 KB); schemas expose opaque `plan` objects. The UI eagerly renders empty assistant messages and repeats three analysis metrics below the conversation.

End-to-end confirmation also reproduces a deterministic TypeError: the coordinator passes a shallow Freezed `toJson()` snapshot containing Phase objects to `PlanTemplate.fromJson`. Normalize the snapshot through the JSON codec before decoding; this applies to every native and Web plan-revision confirmation, independent of provider/network.

Reference inspected: [pi agent-core loop](https://github.com/earendil-works/pi/blob/main/packages/agent/src/agent-loop.ts). We adapt the separation of completed messages, recoverable per-tool results, and terminal errors, not the TypeScript runtime or coding-agent permissions.

## Goals / Non-Goals

**Goals:** Reliable bounded tool iterations; compact safe plan edits; useful error messages; readable Markdown in existing palettes; v1.1.2+23 release.

**Non-Goals:** JavaScript runtime in Flutter, new provider credentials, automatic writes, broader tools, cloud conversation persistence, or production data edits for testing.

## Decisions

1. A model response must end explicitly. EOF is not success. `length` invalidates every tool call in that response; a complete but malformed tool call returns a structured error to the model. Keep the existing eight-turn/twelve-call caps and cancellation checks. Do not hide transport failures with unlimited retries.
2. Extract reusable turn assembly/tool execution/history normalization from UI controller responsibilities. Persist a complete assistant/tool-result sequence; mark unexecuted calls as skipped on approval/cancel/error. Normalize old orphaned histories before reuse, without claiming a skipped write succeeded.
3. Add paginated plan detail reads and accept bounded JSON-pointer edits on `propose_revise_plan` with a digest from the read. Apply only to a deep local copy, validate the full result, and reuse the existing proposal coordinator for confirmation/migration/undo. Preserve unchanged data/IDs. Return schema guidance for full create/replace requests. Compute field-level differences instead of a workout count alone.
4. Use maintained `flutter_markdown_plus` for selectable headings/lists/emphasis/code/tables. Use semantic Fittin colors. Disable image loading and allow only user-tapped HTTP(S) links. No embedded HTML execution. Keep user input plain text.
5. Hide whitespace-only assistant messages in all phases; show status while running and the error card when failed. Remove redundant insight widgets, not the underlying local analytics tool.

## Risks / Trade-offs

- A user's exact provider response is unavailable → reproduce deterministic real-transport failure cases and label mocked-provider validation honestly.
- Index-based patches can become stale → require a content digest before generating a proposal and retain coordinator checks before confirmation.
- Markdown tables/code can overflow small phones → horizontal containment and 320/390 px widget and visual tests.
- Pending proposals remain session-local → history marks unresolved actions unconfirmed and requires a fresh proposal; never silently execute them.

## Migration Plan

No schema migration. Existing conversations remain readable and are normalized at the provider boundary. Publish through the existing signed CI release chain, sync 241 via fast-forward only, deploy the exact CI Web ZIP, preserve current/previous releases, update latest.json last. Roll back the Web symlink if public startup fails.
