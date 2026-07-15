## MODIFIED Requirements

### Requirement: Seamless Session Launch
The system MUST allow users to tap the hero card to smoothly transition into the Active Session Screen with the full multi-exercise workout context loaded or resumed. The Home summary and the launched session MUST resolve to the same active instance and scheduled workout at the moment the launch command is accepted.

#### Scenario: User starts the daily workout
- **WHEN** the user taps the "Today's Workout" hero card
- **THEN** an elegant transition animation takes the user to the `ActiveSessionScreen` with the scheduled workout's ordered exercises, pre-filled set targets, and any current in-progress draft entries loaded
- **AND** the session instance and workout identity match the week/day displayed by the current Home summary.

#### Scenario: User resumes after refresh or relaunch
- **WHEN** the active plan already has a persisted in-progress workout draft whose instance, template, workout, and progression identity match the current schedule
- **THEN** opening the workout logger restores that saved draft instead of generating a fresh session from the current instance state.

#### Scenario: Persisted draft belongs to an earlier workout
- **WHEN** the active instance has advanced but its persisted draft belongs to a previous scheduled workout or an earlier repetition of the same workout ID
- **THEN** opening the workout logger rejects and clears the stale draft
- **AND** it loads the workout currently displayed on Home.

#### Scenario: User taps the hero card repeatedly
- **WHEN** multiple taps arrive before the first session launch finishes
- **THEN** the app performs one session load and opens one Active Session route.
