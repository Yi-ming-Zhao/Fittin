## ADDED Requirements

### Requirement: Individual Workout Log Editing
The system MUST allow the user to reopen a saved workout log and edit that single recorded workout without recreating the entire training day.

#### Scenario: User edits one workout from a recorded day
- **WHEN** the user opens a day that contains multiple recorded workouts and chooses one workout log to edit
- **THEN** the app opens an editor for only that selected workout log
- **AND** saving the edit updates that log without modifying the other workout logs from the same day.

### Requirement: Editable Recorded Set Values
The workout-log editor MUST allow the user to change recorded set values, including completed reps, recorded weight, completion flags, and the workout completion timestamp for the selected workout log.

#### Scenario: User corrects logged set data
- **WHEN** the user changes set reps, set weight, or the completion time in the workout-log editor and saves
- **THEN** the stored workout log reflects the corrected values on the next load
- **AND** the record detail and analytics views render the updated workout data.

### Requirement: Bounded Progression Rewrite After Editing
Saving an edited workout log MUST always update the log itself, but the system MUST only rewrite next-session progression when that edited log is the latest relevant workout that directly determines the current next prescription.

#### Scenario: User edits the latest relevant workout
- **WHEN** the user saves changes to the latest relevant workout log for the active instance
- **THEN** the app updates the stored workout log
- **AND** it recomputes the current instance progression and next-session prescription from that edited workout.

#### Scenario: User edits an older workout
- **WHEN** the user saves changes to a workout log that is not the latest relevant workout for the active instance
- **THEN** the app updates the stored workout log
- **AND** it does not modify the current next-session prescription or current instance progression state.

### Requirement: Legacy Log Compatibility During Editing
The workout-log editor MUST preserve edit support for older workout logs that predate replay metadata, while declining progression rewrites that cannot be performed safely.

#### Scenario: User edits an older schema workout log
- **WHEN** the selected workout log lacks the replay metadata required for progression rewrite
- **THEN** the app still saves the corrected log values
- **AND** it skips any progression rewrite for that save path.
