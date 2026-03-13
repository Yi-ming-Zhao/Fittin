## 1. Seed GZCLP Program Data

- [x] 1.1 Convert the checked-in workbook into a normalized seed source containing the populated Day 1 to Day 4 exercise order, warm-up sets, work sets, and progression metadata.
- [x] 1.2 Register the GZCLP seed in app bootstrap so an empty local database creates or loads the default template and starter instance instead of the squat demo.
- [x] 1.3 Implement a gateway/service that resolves the current scheduled workout summary (day label, primary lift, duration, exercise count) from the active instance.

## 2. Refactor Domain and Persistence for Whole Workouts

- [x] 2.1 Introduce workout-level session domain models for ordered exercise drafts, exercise logs, and set roles (`warmup` vs `working`).
- [x] 2.2 Refactor `ActiveSessionNotifier`, `TrainingState`, and related rule-engine inputs so one active session can hold multiple exercises and preserve edits while navigating.
- [x] 2.3 Update repository and Isar collection models to persist one completed workout log plus the next-session states for every exercise in the workout.
- [x] 2.4 Regenerate Freezed/Isar code and update affected call sites after the model changes land.

## 3. Replace the Demo Session Flow in the UI

- [x] 3.1 Replace the hardcoded Today Workout hero card content and launch path with data from the real GZCLP gateway.
- [x] 3.2 Redesign `ActiveSessionScreen` to show workout-level context, allow switching between exercises, and keep draft entries intact across navigation.
- [x] 3.3 Implement whole-workout completion UX that concludes the session, returns to the dashboard, and refreshes the next workout summary.

## 4. Verification

- [x] 4.1 Add unit tests that verify workbook-seeded day mappings and representative progression transitions, including Bench `3x5+ -> 4x3+` on failure and Squat `+5 kg` on success.
- [x] 4.2 Add provider or widget tests that cover multi-exercise draft persistence, whole-workout logging, and dashboard launch/resume behavior.
- [x] 4.3 Run the relevant automated tests and a manual smoke check of the dashboard-to-session flow before implementation is considered complete.
