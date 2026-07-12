## ADDED Requirements

### Requirement: In-Session Weight Inheritance
The system MUST propagate an explicitly edited actual weight to every later unresolved set of the same exercise without changing target prescriptions, already resolved sets, earlier sets, or other exercises.

#### Scenario: Editing a working weight once
- **WHEN** the user changes the current set weight from 80 kg to 82.5 kg
- **THEN** the current set and all later incomplete, non-cancelled sets of that exercise use 82.5 kg as their actual weight
- **AND** their target weights remain unchanged.

#### Scenario: Editing weight again later
- **WHEN** the user reaches a later set and changes its inherited weight again
- **THEN** that new value applies from the edited set forward to later unresolved sets of the same exercise.

#### Scenario: Preserving resolved and unrelated sets
- **WHEN** weight inheritance is applied
- **THEN** completed or cancelled sets and sets in other exercises retain their existing actual weights.

### Requirement: Cancelled Set Draft State
The active workout draft MUST preserve whether a set was cancelled so restoration and navigation do not present it as the current unresolved set or as a completed set.

#### Scenario: Restoring after cancelling a set
- **WHEN** the user cancels a set and then refreshes or relaunches the app
- **THEN** the cancelled set remains cancelled
- **AND** the session resumes at the next unresolved set.
