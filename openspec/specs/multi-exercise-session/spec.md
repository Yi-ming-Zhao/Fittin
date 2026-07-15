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

### Requirement: In-Session Weight Inheritance
The system MUST propagate an explicitly edited actual weight to every later unresolved set of the same exercise without changing target prescriptions, already resolved sets, earlier sets, or other exercises.

#### Scenario: Editing a working weight once
- **WHEN** the user changes the current set weight from 80 kg to 82.5 kg
- **THEN** the current set and all later incomplete, non-skipped sets of that exercise use 82.5 kg as their actual weight
- **AND** their target weights remain unchanged.

#### Scenario: Editing weight again later
- **WHEN** the user reaches a later set and changes its inherited weight again
- **THEN** that new value applies from the edited set forward to later unresolved sets of the same exercise.

#### Scenario: Preserving resolved and unrelated sets
- **WHEN** weight inheritance is applied
- **THEN** completed or skipped sets and sets in other exercises retain their existing actual weights.

### Requirement: Skipped Set Draft State
The active workout draft MUST preserve whether a set was skipped so restoration and navigation do not present it as the current unresolved set or as a completed set.

#### Scenario: Restoring after skipping a set
- **WHEN** the user skips a set and then refreshes or relaunches the app
- **THEN** the skipped set remains skipped
- **AND** the session resumes at the next unresolved set.

### Requirement: Persisted Active Session Draft
The system MUST persist the in-progress active workout session so the same current draft can be restored after app relaunch or browser refresh. Draft writes MUST preserve local mutation order, and restoration MUST validate the draft's instance, template, workout, and deterministic progression identity against the active schedule.

#### Scenario: User refreshes during an in-progress workout
- **WHEN** the user has already changed reps, weights, completion state, skip state, or exercise selection in the current active workout and then refreshes the app
- **THEN** the app restores the same current in-progress workout draft on resume
- **AND** it does not rebuild the session from the current training instance as though the workout had never started.

#### Scenario: Rapid local mutations finish persistence out of order
- **WHEN** the user records several set actions faster than individual local draft writes complete
- **THEN** the writes are committed in local mutation order
- **AND** the restored draft reflects the newest accepted action rather than an older late write.

#### Scenario: Workout conclusion clears its draft
- **WHEN** a workout concludes successfully while earlier draft writes are still pending
- **THEN** the app drains or invalidates those writes before clearing the draft
- **AND** no late save can recreate the concluded workout draft.

#### Scenario: Active schedule no longer matches the draft
- **WHEN** the active instance or scheduled workout identity differs from the persisted draft
- **THEN** the app does not restore that draft as the current workout.

### Requirement: Local-First Active Session Commands
The system MUST apply accepted set navigation, edit, completion, and skip commands to in-memory session state without waiting for cloud connectivity or backend synchronization.

#### Scenario: Network is slow or unavailable during set logging
- **WHEN** the user performs a valid active-session command while backend synchronization is slow, failing, or offline
- **THEN** the current card and session state update immediately from local state
- **AND** network work does not block or cancel the interaction.

#### Scenario: Local draft persistence is delayed
- **WHEN** an accepted command is waiting for its local draft write
- **THEN** subsequent valid interaction remains responsive
- **AND** final persisted state converges to the accepted command order.

### Requirement: Explicit Workout Conclusion Confirmation
The system MUST require an explicit confirmation step before concluding and persisting the active workout session.

#### Scenario: User taps conclude by mistake
- **WHEN** the user taps the final conclude action from the active workout screen
- **THEN** the app asks for confirmation before saving the workout and advancing progression
- **AND** cancelling that confirmation leaves the active workout draft unchanged.
