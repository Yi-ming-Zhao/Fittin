## MODIFIED Requirements

### Requirement: Today's Workout Hero Card
The system MUST provide a prominent hero card on the Home Dashboard that displays the scheduled workout derived from the currently selected active plan instance, including the day label, primary lift, estimated duration, and exercise count.

#### Scenario: User views the dashboard
- **WHEN** the user opens the app and arrives at the Home Dashboard
- **THEN** a large card displaying the current workout title, day label, estimated duration, and number of exercises from the active plan is visible at the top instead of hardcoded demo content.

#### Scenario: User switches active plans
- **WHEN** the user changes the active plan from the plan library
- **THEN** the hero card updates to the selected plan instance’s scheduled workout without requiring an app restart.
