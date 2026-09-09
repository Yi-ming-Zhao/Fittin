## Purpose

Define safe, deterministic reordering of the remaining training days inside an active microcycle.

## Requirements

### Requirement: Reorder remaining microcycle days
The system SHALL let the user move any uncompleted training day in the active microcycle to the next position and SHALL retain every displaced day exactly once in a deterministic remaining order.

#### Scenario: Leg day is moved to today
- **WHEN** the active microcycle is ordered chest, back, legs, shoulders and the user selects legs for today
- **THEN** the system schedules legs next and keeps chest, back, and shoulders pending exactly once.

#### Scenario: New microcycle begins
- **WHEN** the last pending day in a reordered microcycle is concluded
- **THEN** the next microcycle begins in the template's canonical order.

### Requirement: Reordering is concurrency-safe
The system MUST persist the selected order on the active training instance with a version precondition and MUST refuse stale changes or changes made while a session draft is active.

#### Scenario: Another device advances the plan
- **WHEN** the user confirms a day change after the active instance version has changed
- **THEN** the system refuses the change, reloads the current schedule, and does not lose or duplicate a day.

#### Scenario: Workout draft is in progress
- **WHEN** an unresolved active-session draft exists
- **THEN** the system requires the user to finish or discard that draft before changing today's training day.

### Requirement: Explicit training day skip
The system SHALL let the user skip the next scheduled day after confirmation, preserving training state and producing no completed workout. It MUST reject stale state or an active session draft.

#### Scenario: Skip today's legs
- **WHEN** the user confirms skipping the next leg day
- **THEN** the following scheduled day becomes next, no leg workout is added to history, and the next cycle remains valid.
