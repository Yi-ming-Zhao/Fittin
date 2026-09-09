## Purpose

Define plan-independent training and safe release of recorded days.

## Requirements

### Requirement: Plan independent training
The system SHALL offer a free-training entry with library exercise selection and normal set recording without advancing or replacing the active plan.

#### Scenario: Complete a free session
- **WHEN** a user records exercises in free training
- **THEN** the history and analytics include the session while the active plan and its next day remain unchanged.

### Requirement: Safe recorded day release
The system SHALL distinguish delete-only from delete-and-release. Release MUST not erase later progress or another active draft and MUST refuse stale state.

#### Scenario: Release an older day
- **WHEN** the user releases a recorded plan day after later sessions have been completed
- **THEN** that day becomes available for recording again without deleting later records or rewinding unrelated progression.
