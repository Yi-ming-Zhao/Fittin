## MODIFIED Requirements

### Requirement: Seamless Session Launch
The system MUST allow users to tap the hero card to smoothly transition into the Active Session Screen with the full multi-exercise workout context loaded or resumed.

#### Scenario: User starts the daily workout
- **WHEN** the user taps the "Today's Workout" hero card
- **THEN** an elegant transition animation takes the user to the `ActiveSessionScreen` with the scheduled workout's ordered exercises, pre-filled set targets, and any in-progress draft entries loaded.

#### Scenario: User resumes after refresh or relaunch
- **WHEN** the active plan already has a persisted in-progress workout draft
- **THEN** opening the workout logger restores that saved draft instead of generating a fresh session from the current instance state.
