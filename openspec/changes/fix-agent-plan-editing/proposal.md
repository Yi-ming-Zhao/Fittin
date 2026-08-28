## Why

Plan-editing runs can terminate on malformed tool JSON, silently accept truncated model output, or leave unmatched tool calls after an approval pause. The chat also displays empty assistant cards and redundant analytics cards, and renders Markdown as plain text.

## What Changes

- Adopt pi agent-core's separation of model completion, tool outcomes, and terminal run failures in the Dart harness; return recoverable tool errors to the model within existing budgets.
- Add bounded, digest-checked partial plan edits with explicit tool guidance and meaningful per-field previews, retaining confirmation, conflict detection, and undo.
- Keep tool-result pairs complete through approval, failure, cancellation, stored history, and follow-up requests.
- Render safe themed Markdown, hide empty assistant cards, and remove the three analytics cards without removing analysis tools.
- Publish Android and Web version 1.1.2+23 after focused regression tests and mobile visual checks.

## Capabilities

### New Capabilities

### Modified Capabilities

- `in-app-agent-harness`: Recoverable tools, terminal stream validation, complete message history, and Markdown/error presentation.
- `agent-data-mutations`: Compact plan revision and explicit field-level previews.

## Impact

Flutter Agent controller, protocol, tool registry, chat presentation, tests, Markdown dependency, OpenSpec, and release artifacts. No authentication, backend API, or database schema changes; no production user data is edited during verification.
