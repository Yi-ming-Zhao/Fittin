## Purpose

Define safe exercise substitution inside an active strength-training session.

## Requirements

### Requirement: Replace a pending exercise from the catalog
The system SHALL let the user replace a not-yet-resolved exercise in an active session with a selectable exercise-library entry while retaining the original plan slot, set prescription, and progression identity.

#### Scenario: User replaces a pending barbell row
- **WHEN** the user selects a compatible dumbbell row before completing or skipping any set in that exercise slot
- **THEN** the session uses the selected movement name and canonical ID, keeps the prescribed sets, and records the selected movement in the final log.

#### Scenario: Exercise already has resolved work
- **WHEN** an exercise contains a completed or skipped set
- **THEN** the system disables replacement for that exercise and explains why.

### Requirement: Replacement survives interruption
The system MUST persist the performed movement identity in the active-session draft and restore it without reverting to the template movement.

#### Scenario: App restarts after substitution
- **WHEN** the user replaces an exercise and restarts the app before concluding the workout
- **THEN** the restored draft still shows the selected replacement and all entered set values.
