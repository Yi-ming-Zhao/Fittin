## ADDED Requirements

### Requirement: Today's Workout Hero Card
The system MUST provide a prominent hero card on the Home Dashboard that displays the key details of the scheduled workout for the present day.

#### Scenario: User views the dashboard
- **WHEN** the user opens the app and arrives at the Home Dashboard
- **THEN** a large card displaying the workout title, duration, and exercise count is visible at the top.

### Requirement: Seamless Session Launch
The system MUST allow users to tap the hero card to smoothly transition into the Active Session Screen.

#### Scenario: User starts the daily workout
- **WHEN** the user taps the "Today's Workout" hero card
- **THEN** an elegant transition animation (e.g., slide and fade) takes the user to the `ActiveSessionScreen` with the workout context loaded.
