## Context

Baseline v1.4.0+27 uses 4096 output tokens, eight model turns, twelve tools, a ten-minute run/context boundary and five-minute network timeout. Streaming UI follows every revision with jumpTo. Plan activation reuses a template's instance. Cardio records contain aggregate metrics only. Android identity and signing must remain stable.

## Goals / Non-Goals

**Goals:** Finish long tasks with approval safety; stable mobile reading; non-destructive plan control; progressive editing; reliable independent phone activity recording; private route data; verified multi-platform release.

**Non-Goals:** Wearables, background autonomous Agent work, public route sharing, replacing training engines, changing Android application ID, claiming iOS outdoor validation without a provisioned device.

## Decisions

- Use a cancellation-controlled Agent loop, not global turn/tool/output/time quotas. Provider truncation becomes a persisted continuation, incomplete tools return non-executed results. Retain bounded individual frames, request sizes, concurrency and idle-network detection against resource abuse. Repeated identical no-progress failures pause resumably.
- Keep complete protocol turns in storage, compact context separately and paginate displayed history. Output capability is provider-specific; unknown providers receive no arbitrary fixed output override. Never replay committed actions.
- Coalesce follow scrolling and honor user drag immediately; stable message keys and local streaming rebuilds replace full list jumps. Keep status geometry stable and show partial output on failure.
- Stop preserves instance and its draft; restart creates a fresh UUID and resets schedule/engine state after load review. Use transaction version checks and owner validation. Day preview and workout execution share prescription resolution.
- Editor has overview, day and exercise levels, one shared draft and advanced sections; retain all engine-specific fields rather than dropping complexity from the data model.
- Route capture uses native location independently from AMap presentation. Android uses a user-started location foreground service without requiring Google Play; iOS uses Core Location. Web capture is foreground-only; desktop is viewing/import/manual entry.
- Persist timestamped coordinate-system-tagged route segments, pauses and laps locally in batches. Filter accuracy/jumps, mark missing segments and never bridge recording gaps. Route sync is separately confirmed, owner-authorized, chunked and deletable; Agent and logs get aggregates only.
- Trial decision (2026-10-21): online AMap remains disabled; no keys are created and no license is purchased. GPS, timers and offline route plots remain available independently. Future integration must use the existing fittin application with platform/domain/signature restrictions, consent and licensing checks.

## Risks / Trade-offs

- Provider finite context/output → automatic continuation plus complete-turn compaction, not a promise of an infinite single response.
- OS process termination/power management → saved checkpoints and visible gaps; the user approved a downloadable trial before the real Android 60-minute lock-screen test. Release notes must explicitly state that physical reliability is not yet verified.
- Map authorization pending → keep online maps disabled in the trial; no paid subscription without approval.
- Cross-device stale changes → CAS inside transactions; preserve existing records and drafts.
- No iOS signing account → unsigned build and simulated-location checks only, disclose missing field validation.

## Migration Plan

Use additive native/IndexedDB/backend fields and stores, with fixtures proving old data survives. Deploy compatible backend before clients. Keep prior backend binary and Web release; publish latest.json only after public and signed Android upgrade checks. Sync and archive OpenSpec only after requirements and release evidence are actually complete.

## Open Questions

No remaining product choices for the trial. AMap credentials/authorization and physical Android outdoor validation are deferred by explicit user approval, not reported as completed. Other code, migration, signing and public deployment checks remain required.
