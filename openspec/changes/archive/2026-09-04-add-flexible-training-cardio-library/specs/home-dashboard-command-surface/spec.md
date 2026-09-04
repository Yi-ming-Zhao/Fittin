## ADDED Requirements

### Requirement: Cardio recording home command
The Home dashboard SHALL expose “Record cardio” as its primary secondary command in place of “Switch plan” and SHALL open the typed cardio activity chooser in one interaction.

#### Scenario: User records cardio from Home
- **WHEN** the user taps Record cardio
- **THEN** the activity chooser opens without changing or deactivating the current strength plan

### Requirement: Today training-day chooser
The Home dashboard SHALL expose the remaining days of the active microcycle from the current workout card and SHALL clearly identify any user-adjusted order.

#### Scenario: User brings a later day forward
- **WHEN** the user chooses another pending day and confirms
- **THEN** the Home summary and the next opened session immediately agree on the selected day
