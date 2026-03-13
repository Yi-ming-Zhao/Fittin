## ADDED Requirements

### Requirement: Exercise Progress Analytics Catalog
The system MUST provide a progress analytics view that summarizes strength progress for all logged exercises with sufficient history.

#### Scenario: User opens progress analytics
- **WHEN** the user selects the third bottom-navigation destination
- **THEN** the app shows a progress analytics screen listing exercises with logged history
- **AND** each exercise entry includes enough summary data to compare recent progress before drilling into details.

### Requirement: Estimated and Actual 1RM Separation
The system MUST distinguish formula-derived estimated 1RM values from actual 1RM records.

#### Scenario: User views an exercise without a true max attempt
- **WHEN** an exercise has multi-rep logged sets but no successful logged one-rep max
- **THEN** the app shows estimated 1RM history for that exercise
- **AND** marks actual 1RM as unavailable instead of presenting the estimated value as a true max.

#### Scenario: User views an exercise with a true max attempt
- **WHEN** an exercise has a successful logged one-rep effort
- **THEN** the app records that result as an actual 1RM point
- **AND** displays it separately from estimated 1RM values.

### Requirement: Configurable Estimated 1RM Formula
The system MUST let the user select which estimated-1RM formula is used to calculate analytics values.

#### Scenario: User changes the e1RM formula
- **WHEN** the user selects Brzycki, Epley, Landers, Lombardi, Mayhew, O'Conner, or Wathan in the analytics controls
- **THEN** the app recalculates estimated 1RM summaries and trends using that formula
- **AND** clearly labels the active formula in the analytics UI.

### Requirement: Estimated 1RM Candidate Filtering
The system MUST calculate estimated 1RM values only from eligible logged sets that are suitable for strength estimation.

#### Scenario: Workout contains both heavy and high-rep sets
- **WHEN** an exercise history includes multiple logged sets from the same session
- **THEN** the app ignores ineligible high-noise sets outside the supported rep range for e1RM estimation
- **AND** uses the strongest eligible set for that exercise encounter when building the trend history.

### Requirement: Exercise Detail Trend View
The system MUST provide a drill-down or detail section for each exercise showing recent strength progression.

#### Scenario: User opens an exercise detail view
- **WHEN** the user selects an exercise from the analytics list
- **THEN** the app shows estimated 1RM trend history, actual 1RM history when available, recent best set information, and PR events for that exercise.

### Requirement: Progress Signals and Alerts
The system MUST derive additional progress signals from workout history to help users interpret trends.

#### Scenario: User reviews exercise performance summary
- **WHEN** an exercise has enough logged history for comparison
- **THEN** the app shows recent change windows, PR markers, and stagnation indicators based on the recorded history.

### Requirement: Analytics Summary Cards
The system MUST provide top-level progress context beyond per-exercise history.

#### Scenario: User lands on the analytics screen
- **WHEN** the analytics page loads
- **THEN** the app shows summary cards such as recent training frequency, recent tonnage, and notable exercise progress highlights when enough data exists.

### Requirement: Localized Analytics Chrome
The system MUST render analytics controls and labels in the selected app language.

#### Scenario: User switches app language
- **WHEN** the app language changes between English and Chinese
- **THEN** the analytics screen refreshes its app-owned labels, section titles, formula labels, and empty-state messaging in the selected language.
