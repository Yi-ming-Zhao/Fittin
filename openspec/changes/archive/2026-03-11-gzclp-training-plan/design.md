## Context

The current Fittin v2 prototype is still wired around a single-exercise "Squat Demo". `TodayWorkoutHeroCard` creates a dummy session in memory, `ActiveSessionNotifier` tracks one `TrainingState` plus one list of `SetLog`, and `WorkoutLog` currently represents one exercise instead of a full training session. That is sufficient for the UI prototype, but it does not match the real training flow in `2.0_GZCLP 4-Day 12-Week.xlsx`, where each day contains multiple exercises across T1, T2, and T3 tiers.

The workbook in this repository is the source of truth for the desired first real program. It defines the populated Day 1 to Day 4 exercise lineup, warm-up targets, working sets, and tier-specific progression behavior for the user's current GZCLP setup. The app needs to load that plan offline, present the full workout in the session screen, and persist the result of the whole workout instead of treating each exercise as an isolated demo.

The change touches multiple layers at once:
- domain models (`TrainingState`, `WorkoutLog`, workout template structures)
- persistence (`DatabaseRepository`, Isar collections, seed/bootstrap logic)
- application state (`ActiveSessionNotifier`, today-workout loading)
- presentation (`TodayWorkoutHeroCard`, `ActiveSessionScreen`)

## Goals / Non-Goals

**Goals:**
- Replace the single-exercise active session model with a workout-level session model that can hold multiple ordered exercises and their draft logs.
- Seed the app with a built-in GZCLP 4-day program derived from `2.0_GZCLP 4-Day 12-Week.xlsx`, including exercise order, prescribed sets, warm-up weights, and progression metadata for the populated rows.
- Persist one completed workout session containing all logged exercises, while still evaluating progression separately for each exercise.
- Drive the dashboard hero card and session launch flow from real workout data instead of a hardcoded squat demo.

**Non-Goals:**
- Generic runtime `.xlsx` import or spreadsheet parsing on mobile devices.
- Cloud sync, sharing changes, or redesigning historical analytics in this change.
- Supporting arbitrary user-authored accessory substitutions beyond the exercises already populated in the checked-in workbook.

## Decisions

### 1. Treat the workbook as a build-time seed, not a runtime dependency

The app will not parse `2.0_GZCLP 4-Day 12-Week.xlsx` on device. Instead, implementation will normalize the populated workbook data into a checked-in seed source (JSON asset or Dart constant) that can be loaded during local database bootstrap.

Rationale:
- avoids adding an `.xlsx` runtime parser to the Flutter app
- keeps the seeded program deterministic and testable
- fits the existing `TemplateCollection.rawJsonPayload` storage model

Alternative considered:
- Parse the workbook directly at runtime. Rejected because it adds mobile-only complexity, couples the app to a spreadsheet format, and makes tests and offline bootstrap harder.

### 2. Introduce a workout aggregate for the active session

The active session will be promoted from "one exercise plus one list of sets" to a workout aggregate with:
- workout metadata (`workoutId`, `name`, `dayLabel`)
- an ordered list of per-exercise session entries
- a current exercise index or navigation cursor

Each exercise entry will carry:
- stable exercise identity and progression state
- prescribed set rows separated by role (`warmup` vs `working`)
- mutable user-entered results for the current session

Rationale:
- the workbook describes a whole training day, not isolated exercises
- the UI must preserve edits while moving between exercises
- warm-up rows need to be visible and recordable without affecting progression rules

Alternative considered:
- Keep the current `SessionState` shape and reload one exercise at a time. Rejected because it would make "whole workout" logging and resume behavior fragile and require ad hoc caching outside the state model.

### 3. Persist one workout log and update all exercise states in a single write path

`WorkoutLog` should become a workout-level aggregate containing the ordered exercise logs for the completed session. Progression evaluation will still happen per exercise, but the repository should write:
- one workout session log for historical record
- the updated per-exercise next states for the owning instance

in the same repository transaction path.

Rationale:
- the user asked to record the entire workout, not just one action
- session history is easier to query and restore when a whole workout is one logical record
- it prevents partial saves where logs and next states diverge

Alternative considered:
- Continue storing one log row per exercise and infer workout boundaries from timestamps. Rejected because grouping becomes error-prone and resume/history screens would need extra heuristics.

### 4. Model GZCLP as a recurring 4-day program with progression metadata, not 48 static workouts

The workbook spans 12 weeks, but the app should not hardcode 48 independent workouts. Instead, the seed will encode:
- the 4 recurring workout definitions
- initial working weights and warm-up prescriptions from the workbook
- progression metadata required to reproduce the workbook's tier behavior for the populated exercises

Rationale:
- aligns with the existing rule-engine direction in the codebase
- avoids duplicated workout definitions across weeks
- lets future sessions continue beyond week 12 if the user keeps running the plan

Alternative considered:
- Store every week/day as a literal snapshot. Rejected because it duplicates data, makes edits difficult, and bypasses the progression engine already present in the architecture.

### 5. Use a workout-level session UI with exercise navigation and progress context

`ActiveSessionScreen` should become a workout screen rather than an exercise screen. The recommended layout is:
- a workout header with day label and progress summary
- an exercise navigator (chips, segmented tabs, or pager controls)
- one focused exercise editor at a time using the existing zero-typing set interactions

Rationale:
- keeps the screen manageable for 4 to 6 exercises per session
- preserves the current set-row interaction model
- still gives the user awareness that they are completing one full workout

Alternative considered:
- Render all exercises and all sets in one long scrolling list. Rejected because it makes longer sessions noisy, weakens exercise-level focus, and complicates timer/focus behavior.

## Risks / Trade-offs

- [Risk] Manual transcription from the workbook drifts from the checked-in spreadsheet -> Mitigation: add fixture tests that verify representative day mappings and key progression transitions against the workbook-derived seed.
- [Risk] Refactoring log and state models will touch generated Freezed/Isar code and multiple call sites -> Mitigation: introduce the new aggregate models first, then regenerate code and update repository/provider code in one focused pass.
- [Risk] Whole-workout conclusion could partially persist if logging and state updates happen separately -> Mitigation: make repository conclusion APIs responsible for writing the workout log and next states together.
- [Risk] The first seeded plan only covers populated workbook rows, not every optional accessory slot GZCLP supports -> Mitigation: keep blank slots out of scope for this change and leave template structures extensible for later editing/customization.

## Migration Plan

1. Add the normalized GZCLP seed source and bootstrap it only when the local database has no real template/instance data.
2. Introduce workout-level domain and persistence models, regenerate Freezed/Isar code, and update repository APIs to support whole-workout read/write flows.
3. Refactor `ActiveSessionNotifier` and `TodayWorkoutHeroCard` to load the real scheduled workout from the seeded instance.
4. Replace the dummy session launch path in the UI and verify that the dashboard, session flow, and persistence all use the real program.

Rollback strategy:
- Keep the seed/bootstrap work isolated from unrelated specs.
- If the session refactor proves unstable, the app can temporarily fall back to the old dummy launch path while leaving the seed data and repository changes in place.

## Open Questions

- Should a future follow-up import the user's already completed workbook history, or is seeding from the workbook's configured plan sufficient for the first real in-app version?
- Should blank accessory rows from the workbook eventually surface as optional "add accessory" placeholders, or remain hidden until template editing exists?
