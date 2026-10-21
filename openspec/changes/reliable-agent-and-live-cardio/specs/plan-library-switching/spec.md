## ADDED Requirements

### Requirement: Non-destructive instance lifecycle
Users SHALL stop and resume an instance preserving progress and draft. Restart SHALL create a new instance from the first day after load review, preserving historical records. Lifecycle writes MUST check ownership and expected version atomically; unfinished drafts MUST NOT be silently discarded.

#### Scenario: Stop and resume
- **WHEN** the user stops an instance and later resumes it
- **THEN** the active pointer, progress and saved draft reflect that instance without deleting any history

#### Scenario: Restart a plan
- **WHEN** the user confirms restart after resolving any unfinished draft
- **THEN** a new instance ID starts at the first day and old logs remain unchanged

### Requirement: Concrete day preview
Plan day rows SHALL open week-selectable prescriptions using the runtime resolver, displaying exercises, sets, load rules, rest, types and notes. Unknown load inputs SHALL remain rules instead of fabricated weights.

#### Scenario: Open a periodized day
- **WHEN** the user taps D2 and selects week three
- **THEN** the preview matches the runtime prescription for that week/day
