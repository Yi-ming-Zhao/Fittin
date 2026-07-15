## MODIFIED Requirements

### Requirement: Persisted Active Session Draft
The system MUST persist the in-progress active workout session so the same current draft can be restored after app relaunch or browser refresh. Draft writes MUST preserve local mutation order, and restoration MUST validate the draft's instance, template, workout, and deterministic progression identity against the active schedule.

#### Scenario: User refreshes during an in-progress workout
- **WHEN** the user has already changed reps, weights, completion state, cancellation state, or exercise selection in the current active workout and then refreshes the app
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

## ADDED Requirements

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
