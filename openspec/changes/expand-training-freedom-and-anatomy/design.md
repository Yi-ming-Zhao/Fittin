## Context

Version 1.3.0 stores plan order in instance engine state, guards reordering against active drafts and uses snapshot matching for history progression changes. Recording and history editing currently have different interactions. Catalog identity and theme tokens already exist.

## Goals / Non-Goals

**Goals:** Flexible scheduling without duplicate advancement; plan-independent recording; recording-style history correction; safe delete/release; traceable broad bilingual catalog; accurate equipment visual hints; detailed interactive three-view muscle display; cohesive mobile UI; verified releases.
**Non-Goals:** Claiming a finite catalog contains every conceivable variation, diagnosing injuries from workload, importing copyrighted imagery, silently rewinding unrelated progress, or publishing unsigned iOS binaries as App Store releases.

## Decisions

- Retain stable plan/workout/exercise identities. Skipping changes schedule state without fabricating a completed workout. Bringing a day forward keeps the remaining order stable.
- Free sessions have explicit identity and no progression snapshots. They use the same set editor and analytics log path, never conclude a plan engine.
- History editing reuses recording widgets/state with explicit edit mode; saving preserves log identity and trusted snapshots. It never overwrites an active training draft.
- Delete-only creates a normal tombstone without progression changes. Delete-and-release restores an exact matching latest snapshot when safe; otherwise queues an explicit recovery occurrence without erasing later work. All mutations require owner and version checks and atomicity.
- Catalog expansion is curated and source-traceable. Structured execution attributes describe laterality, grip, stance/angle, recording metric and technique; older records retain their names and IDs. Custom/Agent DTO validation remains bounded.
- Anatomy uses original vector geometry with front/back/side regions, shared muscle identities and theme-derived intensity. It represents completed-set exposure, not physiological recovery or injury risk.
- Use equipment and load semantics, not name substrings, for dumbbell guidance. Clearly distinguish per-hand from combined loads.
- Refine shared mobile primitives and key deep screens; preserve the existing semantic palettes and prohibit cyan/teal accents.

## Risks / Trade-offs

- Concurrent history/schedule edits → compare and commit in the repository transaction and refuse stale requests.
- Legacy logs lack snapshots → never guess a rollback; explicitly present release behavior.
- Catalog aliases can collide → deterministic identity tests and unique alias checks.
- Muscle targets vary with technique → explicit variation fields, conservative primary/secondary assignments, source notes.
- Extensive UI changes → focused widget tests and rendered mobile/deep-route inspection.

## Migration Plan

Add backwards-compatible JSON fields only. Run native/Web data and session regressions, then Android/Web/iOS builds and public release gates. Preserve prior public release and only update Android latest after artifact verification.

## Open Questions

Confirm available iOS signing/distribution credentials before promising public iOS delivery.
