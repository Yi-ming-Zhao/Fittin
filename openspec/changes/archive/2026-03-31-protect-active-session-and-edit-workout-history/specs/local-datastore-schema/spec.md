## ADDED Requirements

### Requirement: Active Session Draft Persistence
The local datastore MUST persist the current active workout draft, including exercise order, current exercise selection, recorded set values, and completion flags, so the workout can resume after app restart or browser refresh.

#### Scenario: User resumes a saved workout draft
- **WHEN** the app reloads while an active training instance still has a saved workout draft
- **THEN** the datastore restores that draft payload for the same user and training instance
- **AND** the app can continue the workout without regenerating the session from scratch.

### Requirement: Editable Workout Log Identity
The local datastore MUST assign and preserve a stable identity for each workout log so later edits target the same stored record on every supported platform.

#### Scenario: User saves a workout and later edits it
- **WHEN** the app creates a workout log and the user later reopens that same workout for editing
- **THEN** the datastore identifies the original log by a stable log identifier
- **AND** saving the edit updates that existing record instead of creating a duplicate workout log.

### Requirement: Workout Log Replay Metadata
The local datastore MUST preserve optional replay metadata for workout logs created by the updated conclusion flow so the system can safely decide whether a later edit may rewrite progression.

#### Scenario: User edits the latest replay-capable workout
- **WHEN** a recently saved workout log includes pre-conclusion and post-conclusion progression snapshots
- **THEN** the datastore exposes that metadata to the workout-log update flow
- **AND** the app can use it to recompute the current instance state from the edited workout when allowed.
