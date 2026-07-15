## Context

Home and Active Session currently resolve workout state through separate asynchronous paths. The Home summary is rebuilt from the active training instance, while Active Session restores one persisted draft keyed only by the long-lived instance ID. A draft from Day 2 therefore still passes the current restore check after the same instance advances to Day 3.

The active-session provider is also recreated whenever cloud synchronization increments `syncRefreshProvider`. Meanwhile, every set edit starts an unawaited local draft write, workout conclusion clears the draft without draining those writes, and card completion waits for two decorative animations before mutating provider state. Together these behaviors create a reproducible race: progression advances locally, an older write recreates the previous draft, sync rebuilds the provider, and the stale draft is restored.

The card recognizer also projects release velocity only after choosing an axis from displacement. A short vertical fling with little sampled displacement can default to the horizontal axis, and all gestures are disabled during the pre-commit delay. The interaction must follow an offline-first model: local session state is authoritative during the workout, visual response is immediate, and persistence or cloud synchronization follows without gating input.

## Goals / Non-Goals

**Goals:**

- Keep Home and the session opened from Home on the same active instance and workout identity.
- Preserve a valid in-progress draft while rejecting a draft from an already advanced workout.
- Make session launch, set commands, and draft writes deterministic under rapid input.
- Recognize both deliberate drags and short high-velocity flicks in all four supported directions.
- Keep gesture feedback independent of network latency and resilient to local persistence delay.

**Non-Goals:**

- Redesigning the active-session visual language or adding new gestures.
- Synchronizing every in-progress set draft to the backend.
- Changing the backend API, datastore schema, or global claim/pull merge policy.
- Replacing Riverpod or the existing local repositories.

## Decisions

### 1. Keep an active workout stable across background sync refreshes

`activeSessionProvider` will no longer rebuild solely because `syncRefreshProvider` changes. Summary and template providers will still refresh from synchronized data, while an already open workout remains a local interaction boundary. Plan switching continues to invalidate the active session explicitly.

When Home launches or resumes a workout, the notifier will compare the candidate session's `instanceId`, `templateId`, `workoutId`, and deterministic progression token with the current locally resolved schedule. The token derives from the workout index and progression-driving week, stage, and base-weight state, so a repeated workout ID in a later week cannot accept an older draft. A legacy draft without a token may pass one structural prescription comparison and is then upgraded. A mismatched in-memory or persisted draft is stale, is cleared, and is replaced with the current scheduled session.

Alternative considered: rebuild the active-session notifier after every sync and try to restore again. This retains the current rollback window and lets network timing replace live user input, so it is rejected.

### 2. Make launch a single-flight operation

The notifier will share one in-flight start/restore future, and the Home card will take an immediate widget-local navigation lock before awaiting it. This protects both the data load and the route push from rapid double taps. Loading state will also disable the card action for accessibility and visible feedback.

Alternative considered: rely only on provider rebuilds to disable the card. Two taps can arrive before the next frame, so provider state alone is insufficient.

### 3. Serialize local draft persistence and close it before conclusion

Provider state continues to update synchronously first. Draft saves are appended to a local future chain in mutation order, with errors contained so one failed save does not break later writes. Successful conclusion closes new draft writes, drains the chain, persists progression, then clears the draft. If conclusion fails, draft persistence reopens and the captured workout is saved again.

This keeps all gesture work local and deterministic; backend synchronization remains an unawaited post-conclusion recovery task.

Alternative considered: debounce saves. Debouncing reduces writes but creates a larger data-loss window on refresh and still needs ordering around conclusion, so simple serialization is preferred.

### 4. Resolve gestures from distance or velocity and commit state immediately

The recognizer will accept a gesture when the dominant displacement passes the existing distance threshold or the dominant release velocity passes a minimum fling threshold. If no axis was locked during movement, the dominant velocity component chooses the axis. The chosen sign determines left/right or up/down.

The corresponding notifier command executes immediately at gesture end. Fly-out and check animations become decorative, short, and non-blocking; they cannot cancel or delay the state mutation. A brief transition lock prevents duplicate resolution of the same displayed card, while the next local state is already committed.

Alternative considered: wait for animation completion before changing state. Flutter ticker futures can be cancelled by a later `forward(from: 0)`, leaving awaited completion code unresolved, which is the current lost-command failure.

### 5. Verify behavior at the command boundary

Provider tests will cover stale identity rejection and deliberately reordered repository writes. Widget tests will use high-velocity flings, rapid taps, and a 390 x 844 phone viewport, asserting local state before long animations or persistence complete. Tests will also confirm one accepted gesture produces exactly one command.

## Risks / Trade-offs

- [A cloud refresh advances the active instance while a user is already training] → Keep the open session stable; revalidate only when entering or resuming from Home, avoiding mid-set replacement.
- [Clearing a mismatched draft removes unfinished work from an older scheduled day] → Clear when any stable schedule or prescription identity differs from the current workout; this is preferable to silently recording against the wrong day.
- [Serialized writes add a small conclusion wait] → Writes are local and remain outside gesture latency; only final conclusion drains them before clearing.
- [Very low fling thresholds cause accidental commands] → Require either the existing 56 px displacement or a deliberate dominant-axis release velocity, and preserve the short transition lock.
- [Global cloud hydration order remains a separate concern] → Keep this patch scoped and add regression coverage that sync refresh cannot rebuild or roll back a live active session.

## Migration Plan

No schema migration is required. Existing valid drafts continue to restore. The first launch after deployment clears only drafts whose instance/template/workout identity no longer matches the active schedule. The change can be rolled back by reverting the provider and gesture commits; stored session JSON remains compatible.

## Open Questions

None for implementation. Broader cloud merge ordering should be handled as its own OpenSpec change because it affects first-login data ownership beyond active-session interaction.
