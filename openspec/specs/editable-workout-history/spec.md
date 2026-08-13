# editable-workout-history Specification

## Purpose
Define how saved workout logs can be safely reopened, corrected, and replayed without breaking unrelated history or losing newly captured training context.
## Requirements
### Requirement: Individual Workout Log Editing
The system MUST allow the user to reopen a saved workout log and edit that single recorded workout without recreating the entire training day.

#### Scenario: User edits one workout from a recorded day
- **WHEN** the user opens a day that contains multiple recorded workouts and chooses one workout log to edit
- **THEN** the app opens an editor for only that selected workout log
- **AND** saving the edit updates that log without modifying the other workout logs from the same day.

### Requirement: Editable Recorded Set Values
The workout-log editor MUST allow the user to change recorded set values, including completed reps, recorded weight, recorded RPE, completion flags, and the workout completion timestamp for the selected workout log.

#### Scenario: User corrects logged set data
- **WHEN** the user changes set reps, set weight, or the completion time in the workout-log editor and saves
- **THEN** the stored workout log reflects the corrected values on the next load
- **AND** the record detail and analytics views render the updated workout data.

#### Scenario: User corrects recorded RPE and unit context
- **WHEN** the user edits a saved workout log that includes target or actual RPE and a chosen display unit
- **THEN** the editor preserves those fields during load
- **AND** saving the edit updates the same workout log with the corrected RPE and unit context instead of dropping them.

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

### Requirement: Agent workout-log changes use history safeguards
Agent-proposed workout-log creation, editing, and deletion SHALL preserve log identity, snapshots, owner scope, validation, sync tombstones, and the existing latest-log progression-rewrite constraints.

#### Scenario: Confirmed latest-log correction
- **WHEN** the current instance still matches the corrected latest log's post-conclusion snapshot
- **THEN** the log and recomputed instance progression commit together and the action is undoable
