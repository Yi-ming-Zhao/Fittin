## Context

The app's active workout flow currently treats `WorkoutSessionState` as transient UI state inside `ActiveSessionNotifier`. That keeps routine interactions simple, but it means a browser refresh or process restart recreates today's session from the current training instance instead of restoring the in-progress draft that the user was editing. The final conclude action is also executed immediately from the active-session screen, so an accidental tap can both log a workout and advance progression without confirmation.

Completed workout history has a second structural limitation: logs are append-only. Repositories expose `logWorkout` and fetch methods, but no stable `logId`, update path, or replay metadata for recomputing progression after a correction. The training engines are deterministic and local-first, and current next-session prescriptions depend only on the prior relevant completed workout, which gives us a bounded way to support edits without attempting to replay the entire history chain.

## Goals / Non-Goals

**Goals:**
- Persist active workout drafts across refresh/relaunch on native and web clients.
- Require explicit confirmation before final workout conclusion mutates logs and progression state.
- Support editing a saved workout log by stable identity, including sets and completion timestamp.
- Recompute current instance progression only when the edited workout is the latest relevant session that directly determines the next prescription.
- Keep analytics, record detail, and today-workout resume behavior aligned with the edited data.

**Non-Goals:**
- Rebuild the workout logger UI beyond the required confirmation affordance and edit entry point.
- Support arbitrary full-history progression replay across multiple prior workouts.
- Persist unsaved draft state for history-edit forms across browser refresh.
- Introduce cloud conflict-resolution UI for concurrent workout-log edits in this change.

## Decisions

### 1. Persist active session drafts as repository-owned local state
The active session draft will move from being memory-only to a repository-backed record keyed by the active training instance and user scope. `ActiveSessionNotifier` will hydrate from persisted draft state on start/resume, and every session mutation that changes reps, weights, completion flags, or current exercise index will overwrite the stored draft.

Rationale:
- fixes the web-refresh loss at the actual source instead of masking it in UI
- preserves one draft per active instance without inventing a separate cache layer
- keeps native and web behavior aligned through the existing repository abstraction

Alternative considered:
- Store draft state only in browser session storage. Rejected because the bug affects the core app contract and the same resume behavior should work after native relaunch as well.

### 2. Confirm before conclusion, but do not confirm simple screen exit
The destructive boundary is the final conclude action, not merely leaving the screen. The active-session screen will show an explicit confirm dialog before calling the conclusion path. Closing the screen without concluding will just preserve the draft for later resume.

Rationale:
- removes the highest-risk mis-tap without adding friction to routine navigation
- pairs naturally with persisted drafts, so “leave and resume” stays cheap while “commit and advance progression” stays deliberate

Alternative considered:
- Prompt on both close and conclude. Rejected because it adds double friction and draft persistence already protects against accidental screen exits.

### 3. Give workout logs stable identity plus replay metadata
`WorkoutLog` will gain a first-class `logId` plus optional replay metadata that captures enough context to rebuild the instance state around the logged workout. New logs will store:
- the pre-conclusion instance snapshot
- the post-conclusion instance snapshot

These snapshots will include current workout index, per-exercise training states, and engine state needed by the program engines.

Rationale:
- log editing needs a durable primary key across Isar and IndexedDB backends
- latest-log progression rewrites are not reliable if we only keep the post-write instance and the visible log payload
- snapshotting keeps replay deterministic without requiring a full historical event stream

Alternative considered:
- Reconstruct pre-conclusion state by scanning older logs. Rejected because older logs do not currently encode enough engine-state detail and periodized plans would become fragile.

### 4. Limit progression rewrites to the latest relevant workout log
Editing any workout log will always update the stored log and derived analytics. A progression rewrite will happen only when the edited log is still the latest relevant session for the active instance and therefore the one that determines the next prescription. Older logs will remain editable, but they will not mutate current next-session state.

For existing legacy logs without replay metadata, the edit flow will still save corrected values but must skip progression rewrite and surface that behavior clearly in the UI.

Rationale:
- matches the current single-step dependency model used by the training engines
- keeps implementation bounded and explainable
- avoids promising full historical recomputation that the current data model cannot safely support

Alternative considered:
- Recompute progression for any edited historical workout. Rejected because it requires a broader event-sourcing or chain-replay model than the app currently has.

### 5. Reuse workout-detail drilldown as the edit entry point
The date drilldown flow already lands on `WorkoutRecordDetailScreen` with the relevant logs for that day. This screen will remain the review surface and gain a per-log edit affordance that opens an editor for a single `WorkoutLog`.

Rationale:
- keeps analytics navigation intact
- matches the product decision to edit at single-workout granularity rather than whole-day bulk editing
- avoids introducing a second history screen just for corrections

Alternative considered:
- Replace the day detail screen with direct inline editing for every log on the page. Rejected because it would overload a review screen and complicate save/cancel state.

## Risks / Trade-offs

- [Risk] Draft persistence could leave stale sessions after a successful conclusion or plan switch.  
  Mitigation: clear draft storage on successful conclusion, active-instance replacement, and invalid instance/template mismatch at hydration time.

- [Risk] Snapshot metadata increases workout-log payload size.  
  Mitigation: store only the minimum deterministic replay fields already present in the instance model rather than duplicating unrelated template data.

- [Risk] Legacy logs cannot safely rewrite progression.  
  Mitigation: allow content edits but explicitly gate progression rewrite on replay metadata availability.

- [Risk] Web and native repositories could diverge in update semantics.  
  Mitigation: add parallel repository methods and tests for both backends, using the same domain payloads and identity rules.

## Migration Plan

1. Add `logId`, draft-state storage, and replay snapshot fields to domain/storage models.
2. Introduce repository APIs for draft save/load/clear and workout-log update/fetch-by-id.
3. Update active-session state flow to hydrate and persist drafts, and add conclude confirmation.
4. Add workout-history editing flow and hook analytics/detail refresh to the update path.
5. When creating new logs, write replay metadata so future latest-log edits can rewrite progression.
6. Leave existing logs readable and editable without replay rewrite; do not backfill inferred snapshots.

Rollback strategy:
- draft persistence can be disabled by stopping hydration and clearing the draft state key without touching stored workout logs
- replay metadata is additive, so old readers can ignore it if needed

## Open Questions

- None for this change. Product behavior is fixed as: single-log editing, latest-relevant-only progression rewrite, and no history-edit draft persistence across refresh.
