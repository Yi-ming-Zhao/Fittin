## ADDED Requirements

### Requirement: Recording interaction for history
The history editor SHALL reuse the workout recording interaction for exercise navigation, set completion and weight/repetition controls, preserving timestamps, IDs, snapshots and all unedited values.

#### Scenario: Correct a historical session
- **WHEN** a user edits and saves a recorded workout
- **THEN** only that log changes, the live draft remains intact, and progression is recomputed only under existing snapshot safeguards.

### Requirement: Separate deletion choices
The history screen SHALL offer clearly labeled delete-only and delete-and-release choices for plan sessions and explain their progression impact.

#### Scenario: Delete history only
- **WHEN** the user selects delete-only
- **THEN** the record is deleted through the normal sync path without changing the plan schedule.
