## Context

Fittin is a Flutter local-first application backed by Isar on native platforms and IndexedDB on Web. Templates, training instances, workout logs, and body metrics already flow through owner-scoped repositories and a durable sync queue. The Go backend provides account, sync, and media APIs through the public Alibaba Cloud nginx origin. This change adds a user-supplied OpenAI-compatible model without making Fittin a credential custodian or allowing model latency to control local mutations.

The implementation must work on Android, iOS, and Web, preserve existing local data during schema upgrades, retain all five semantic palettes, and remain usable at 390px and smaller widths. Web cannot safely persist model keys and cannot reliably call arbitrary provider origins because of CORS, so it requires an authenticated relay.

## Goals / Non-Goals

**Goals:**

- Provide a streaming, bounded Agent loop using the common Chat Completions tool-call contract.
- Expose only typed, owner-scoped, bounded local tools and keep all writes behind an explicit semantic preview.
- Make confirmed writes atomic, idempotent, concurrency-safe, auditable, and undoable.
- Preserve active plan progress across compatible template revisions.
- Support native direct connections and a secure, stateless Web relay.
- Deliver a polished sixth-tab interface using existing theme tokens and bilingual copy.

**Non-Goals:**

- Sync model credentials, conversations, action audit records, or raw model traffic.
- Expose progress-photo bytes or metadata, account credentials, application settings, filesystem access, arbitrary HTTP headers, code execution, or hosted tools.
- Support Anthropic-native, Responses-native, MCP, voice, or image protocols in v1.1.0.
- Publish a signed iOS artifact without an existing App Store signing pipeline.

## Decisions

### Use a small platform-neutral orchestration core

`AgentModelClient` emits normalized text deltas, tool-call deltas, completion, and failure events. `AgentRunner` owns a maximum of eight model turns and twelve tool calls, serializes calls that affect the same run, and stops when a proposal awaits approval. A streaming Chat Completions client parses fragmented SSE and also accepts a normal JSON response when a compatible server ignores `stream: true`.

This avoids a large agent SDK dependency and keeps provider-specific parsing testable. The alternative of adopting a hosted Agent SDK would reduce protocol code but would not support arbitrary Base URLs or Flutter Web consistently.

### Store one per-device provider profile

Base URL and model ID use ordinary device preferences. Native API keys use `FlutterSecureStorage`; Web keys live only in the running process. Release builds require HTTPS URLs without userinfo, query, or fragment; debug native builds additionally allow loopback HTTP. The app appends `/chat/completions` to a normalized base ending in `/v1` or another provider path. Connection testing makes one small forced `ping` tool call and discloses that it may cost provider tokens.

Multiple profiles and arbitrary headers are deferred so the secret surface and compatibility matrix remain bounded.

### Separate read execution from mutation proposals

`AgentToolRegistry` owns JSON schemas and handlers. Read tools execute immediately through existing owner-scoped repositories and return bounded, locally aggregated results. Write tool handlers validate arguments and create one `AgentMutationProposal`; they never call a persistence method. The runner returns `pending_user_approval` to the model and pauses.

`AgentMutationCoordinator` re-reads target records on confirmation, verifies versions or canonical payload digests, and commits a mutation group with an operation UUID. Repeated confirmation returns the existing result. A rejected proposal leaves no data changes. Model output cannot bypass this coordinator.

### Add a local mutation transaction abstraction

Native uses a single Isar write transaction covering affected entities, sync-queue rows, and the local action record. Web upgrades IndexedDB from version 1 to 2, adds `agent_conversations` and `agent_actions`, and gains a multi-store read/write batch method. Existing stores are never deleted or recreated.

Action records retain bounded before/after JSON, target versions, status, and a user-facing summary. Undo revalidates that the target still equals the recorded after-version and applies a newer inverse write through the normal sync path. Conversations and actions are owner-partitioned locally but are not remote sync entities.

### Revise active plans by forking and migrating

Agent plan edits always preserve IDs for unchanged phases, workouts, exercises, and stages. Built-in or previously instantiated templates are forked. When the source is active, a migration service maps the next workout by stable workout ID, preserves training maxes and compatible engine fields, builds starter states for the revision, and overlays prior state by stable exercise ID. Removed and newly initialized items are listed in the preview. Template, active instance, active selection, sync rows, and action record commit together.

The alternative of mutating an active template in place would make historical logs resolve against changing program definitions; restarting the plan would unnecessarily discard progress.

### Treat workout progression effects explicitly

Historical log creation never advances the active instance. Editing or deleting the newest log may rewrite or roll back progression only when its pre/post snapshots and the current instance form an exact chain. Older edits affect history and analytics only. The proposal card states which behavior will occur before confirmation.

### Relay Web traffic without retaining credentials

`POST /v1/agent/chat-completions` requires a valid Fittin bearer session. It accepts a provider base URL, ephemeral provider key, and a bounded Chat Completions payload. The server resolves and dials only public HTTPS addresses, disables environment proxies and redirects, pins the validated address for the connection, caps request/response bytes and concurrency, and streams only safe upstream response headers. It never logs or stores request bodies, credentials, or responses.

nginx gives this exact route a dedicated rate zone, disables response buffering, and uses a longer read timeout. Native clients bypass the relay and therefore do not reveal model credentials to Fittin.

### Use an editorial training-console visual direction

The Agent screen reads as a compact training console rather than a generic chat clone: a strong model-status header, restrained message typography, timeline-like tool activity, metric-led insight cards, and ledger-style mutation diffs. All colors come from the resolved Fittin theme. The tab order is Today, Plans, AI, PR, Body, Me; on narrow screens inactive tabs can collapse labels while retaining 44px targets and semantics.

## Risks / Trade-offs

- **Provider dialects differ despite claiming OpenAI compatibility** → Normalize only the common Chat Completions subset, test forced tool calling, parse streaming and JSON, and report unsupported capability before a run.
- **Web relay could become an SSRF or paid open proxy** → Require Fittin auth, validate and pin public HTTPS targets, disable redirects/proxies, cap concurrency/bytes/time, and rate-limit by user and IP.
- **A provider sees selected private fitness data** → Show first-use disclosure, execute reads only when called, return aggregates where possible, and never send photos or credentials.
- **Concurrent sync invalidates a preview or undo** → Carry target version/digest and refuse rather than merge implicitly.
- **Atomic semantics differ between Isar and IndexedDB** → Centralize mutation groups behind platform implementations and test interrupted/multi-store cases.
- **Six tabs crowd small screens** → Use short AI/PR labels, compact inactive presentation, fixed accessible targets, and visual regression at 320–390px.
- **Local action history cannot be undone from another device** → State this in the UI; inverse writes are synced once initiated on the originating device.

## Migration Plan

1. Add local Agent stores and upgrade IndexedDB additively before enabling the UI.
2. Ship the backend relay and nginx streaming route, verify authentication and public readiness, then deploy Web.
3. Preserve the prior backend binary and current/previous Web release for immediate rollback.
4. Publish `v1.1.0+21` only after main CI, real-provider canary, Web phone regression, and Android upgrade verification pass.
5. A rollback may restore the backend binary and Web symlink; local Agent stores remain harmless and additive. A bad signed mobile release is superseded by a new patch rather than moving the tag.

## Open Questions

None. The implementation defaults and exclusions are fixed by the approved plan.
