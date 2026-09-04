## ADDED Requirements

### Requirement: Performed exercise override
An active session SHALL retain the immutable plan-slot ID separately from a replaceable performed-exercise ID and name so that substitution changes the log identity without changing progression ownership.

#### Scenario: Substituted exercise is concluded
- **WHEN** the user completes a session with a substituted movement
- **THEN** progression applies to the original slot and the workout log identifies the performed catalog movement

### Requirement: Substitute metadata draft persistence
The active-session draft SHALL persist the performed exercise ID, name, equipment/load display behavior, and replacement marker.

#### Scenario: Scheduled session validation runs after substitution
- **WHEN** the app validates a restored substituted draft against the current schedule
- **THEN** it compares immutable slot and set-prescription fields while preserving the performed movement override
