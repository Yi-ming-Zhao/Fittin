# home-screen Specification

## Purpose
TBD - created by archiving change fittin-redesign. Update Purpose after archive.
## Requirements
### Requirement: Training-State Home Screen
The system MUST provide a home screen that surfaces the user's current training state, including active-session progress and near-term training context.

#### Scenario: User opens the home screen with an active session
- **WHEN** the user opens the home screen while a workout session is in progress
- **THEN** the screen highlights the in-progress session, current completion state, and the next exercise to resume.

### Requirement: Home Performance Snapshot
The home screen MUST summarize short-horizon performance and activity signals without requiring navigation into analytics screens.

#### Scenario: User scans current performance
- **WHEN** the user opens the home screen
- **THEN** the screen shows cycle progress, a recent e1RM summary, and an activity chart
- **AND** it provides quick actions for switching plans or opening deeper progress views.

