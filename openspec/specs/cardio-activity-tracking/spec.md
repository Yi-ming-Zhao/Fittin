## Purpose

Define typed cardio activity definitions and validated cardio records.

## Requirements

### Requirement: Typed cardio activity library
The system SHALL provide built-in running, incline walking, cycling, rowing, stair climbing, swimming, elliptical, and generic cardio definitions whose required and optional metrics match the activity, and SHALL let users create custom definitions from the supported metric vocabulary.

#### Scenario: Record incline walking
- **WHEN** the user chooses incline walking
- **THEN** the editor requires duration, speed, and incline and does not require running pace.

#### Scenario: Record a run
- **WHEN** the user chooses running and enters distance plus duration
- **THEN** the system derives pace and average speed while allowing cadence, heart rate, elevation, calories, and notes when available.

### Requirement: Validated cardio records
The system MUST store canonical SI values, preserve the user's display unit, validate activity-specific ranges, and soft-delete records with owner and version metadata.

#### Scenario: Invalid incline is entered
- **WHEN** incline is outside the supported 0–40 percent range
- **THEN** the record is not saved and the invalid field receives a clear localized error.

#### Scenario: User saves cardio offline
- **WHEN** a signed-in user records cardio without network access
- **THEN** the local record is immediately visible and queued for later owner-scoped synchronization.
