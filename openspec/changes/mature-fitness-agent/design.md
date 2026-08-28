## Context

Fittin v1.1.2 has a Dart/Riverpod runner, proposal-only tools and owner-scoped local repositories. Existing approvals, interrupted runs and runtime errors are not durable. The review found nullable snapshot, transaction guard, trusted-input and account-reference defects.

## Goals / Non-Goals

**Goals:** Correct local mutations, complete previews, durable approval continuation, safe interruption recovery, bounded context, explicit fitness preference memory, provider diagnostics and mobile usability.

**Non-Goals:** General-purpose assistant tools, shell/MCP/subagents, photos, account mutations, automatic training writes, background model spending, cloud conversation/memory sync.

## Decisions

- Keep Dart/Riverpod and Chat Completions. Adopt pi-style typed events and Codex-style stable run/turn/item identities rather than embedding a foreign runtime.
- Validate identity, target digest/version and active drafts inside the business transaction. Use SHA-256 canonical snapshots, accepting legacy digests only for existing undo records. Null fields in complete snapshots are replacements, not omissions.
- Strict workout input exposes only editable business fields; local code owns instance IDs and progression snapshots. One semantic diff is persisted in the proposal and displayed without model-authored omissions.
- Durable checkpoints contain owner, run identity, counters, conversation, pending proposal and structured outcome. Reconcile committed operation IDs on recovery before any provider request. Recover into an explicit interrupted state; do not automatically spend after process restart.
- Separate app transcript from bounded model context. Preserve whole tool groups, original goal, decisions, operation IDs and entity references. Default context 32768 tokens with 4096 output reserve and 75% compaction threshold. Unknown model limits are user-configurable, not falsely detected.
- Automatically extract only explicit allowlisted preference statements with provenance. Store at most 50 entries per account, support disabling/editing/deleting, and exclude keys, raw measurements, diagnoses and inferred health information.
- First response 45s, stream idle 60s, total 5m. Retry retryable statuses at most twice before observable output/committed writes; honor bounded Retry-After. No silent provider fallback.
- Add indexed local runtime/memory stores (IndexedDB v3 and additive Isar collection). Keep 200 diagnostic events without prompts, outputs, keys or business data. Page history and prune bounded retained records.

## Risks / Trade-offs

- Provider variability → explicit compatibility profile and fixtures, unknown fields remain unknown.
- Approximate token estimation → conservative UTF-8/token budget plus request byte cap.
- Mobile process termination → persisted safe checkpoints; incomplete streams cannot execute tools.
- Memory false positives → only explicit finite allowlisted categories, source evidence, visible deletion and opt-out.
- Real-provider success cannot be inferred from mocks → release gate remains incomplete until a user-supplied ephemeral key passes canary.

## Migration Plan

Add stores without deleting or rewriting existing business rows. Normalize legacy conversations on load; legacy undo digests remain readable. Validate old Isar and IndexedDB v1/v2 fixtures before release. No production deployment or latest.json change until platform and live-provider gates pass.

## Open Questions

No product decisions remain. A live provider key and real-device canary are external verification prerequisites, not permission to invent credentials or claim success.
