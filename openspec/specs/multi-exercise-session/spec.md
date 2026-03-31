# multi-exercise-session Specification

## Purpose
Define the workout-level active session model so one scheduled workout can hold multiple exercises, drafts, and a single completion record.
## Requirements
### Requirement: Workout Session Composition
The system MUST initialize an active session from an ordered workout definition and create draft logs for every prescribed exercise in that workout, including warm-up and working sets.

#### Scenario: User opens GZCLP Day 1
- **WHEN** the user launches the scheduled Day 1 workout from the dashboard
- **THEN** the active session contains the Day 1 exercises from the seeded plan in workbook order, and each exercise exposes its prescribed warm-up and working sets with pre-filled target reps and weights.

### Requirement: Exercise-to-Exercise Draft Persistence
The system MUST allow the user to move between exercises within the same active session without losing recorded reps, weights, or completion state.

#### Scenario: User switches between exercises mid-session
- **WHEN** the user records part of Squat, navigates to Barbell Row, and then returns to Squat
- **THEN** the previously entered set values and completion markers remain intact for both exercises.

### Requirement: Whole Workout Conclusion
The system MUST conclude and persist the entire workout as one session record while evaluating progression separately for each exercise that has progression rules.

#### Scenario: User finishes a full workout
- **WHEN** the user taps the final conclude action after recording multiple exercises in the same workout
- **THEN** the app stores one workout log containing all exercise results and updates each exercise's next-session state according to its own completed set results.

### Requirement: Persisted Active Session Draft
The system MUST persist the in-progress active workout session so the same draft can be restored after app relaunch or browser refresh.

#### Scenario: User refreshes during an in-progress workout
- **WHEN** the user has already changed reps, weights, completion state, or exercise selection in an active workout and then refreshes the app
- **THEN** the app restores the same in-progress workout draft on resume
- **AND** it does not rebuild the session from the current training instance as though the workout had never started.

### Requirement: Explicit Workout Conclusion Confirmation
The system MUST require an explicit confirmation step before concluding and persisting the active workout session.

#### Scenario: User taps conclude by mistake
- **WHEN** the user taps the final conclude action from the active workout screen
- **THEN** the app asks for confirmation before saving the workout and advancing progression
- **AND** cancelling that confirmation leaves the active workout draft unchanged.

