## ADDED Requirements

### Requirement: Workout Recording Mode Preference
The profile settings screen MUST let the user select card recording or traditional recording, MUST explain the interaction difference, and MUST persist the selection locally.

#### Scenario: Selecting card recording
- **WHEN** the user selects card recording in settings
- **THEN** future and resumed active workouts show the live card stack with swipe gestures.

#### Scenario: Selecting traditional recording
- **WHEN** the user selects traditional recording in settings
- **THEN** future and resumed active workouts show the traditional current-set controls with a centered completion action.

#### Scenario: Restarting the app
- **WHEN** the user relaunches the app after selecting a recording mode
- **THEN** the previously selected recording mode remains active without requiring sign-in.
