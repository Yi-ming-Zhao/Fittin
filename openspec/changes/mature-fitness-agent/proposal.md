## Why

The current fitness Agent can propose changes but cannot durably continue a task after approval or interruption. The review also identified nullable-value undo, concurrency, account-lifecycle, preview completeness and analytics-range defects that must be corrected before expanding autonomy.

## What Changes

- Close mutation boundaries with transaction-local preconditions, trusted log DTOs, full semantic diffs, active draft protection and account epochs.
- Persist runs, events and checkpoints; resume after approval and recover interruptions without replaying committed writes.
- Budget context, retain complete tool pairs, and automatically remember only explicit allowlisted training preferences locally with user controls.
- Add provider capabilities, bounded retries, streaming deadlines, local diagnostics and mobile run timeline.
- Add additive IndexedDB v3/Isar stores and deterministic fitness evaluations; gate release on real-provider and platform validation.

## Capabilities

### New Capabilities

- `agent-runtime-recovery`: Durable events, checkpoint recovery, steering, context budgets, provider capabilities and diagnostics.
- `agent-fitness-memory`: Account-local explicit preference memory with bounded retention and management.

### Modified Capabilities

- `agent-data-mutations`: Transaction-local guards, trusted inputs, complete diffs and draft protection.
- `in-app-agent-harness`: Approval continuation, account lifecycle and recoverable mobile runs.
- `agent-web-relay`: Streaming deadline alignment and bounded safe diagnostics.

## Impact

Flutter application/domain/data/presentation layers, native Isar and Web IndexedDB schema, authenticated Go relay, regression/evaluation fixtures and OpenSpec. Existing business data and cloud sync contracts are preserved. No shell, MCP, photos, account tools, general-purpose subagents or background autonomous execution are added.
