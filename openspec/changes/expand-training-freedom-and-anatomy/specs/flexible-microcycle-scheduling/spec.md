## ADDED Requirements

### Requirement: Explicit training day skip
The system SHALL let the user skip the next scheduled day after confirmation, preserving training state and producing no completed workout. It MUST reject stale state or an active session draft.

#### Scenario: Skip today's legs
- **WHEN** the user confirms skipping the next leg day
- **THEN** the following scheduled day becomes next, no leg workout is added to history, and the next cycle remains valid.
