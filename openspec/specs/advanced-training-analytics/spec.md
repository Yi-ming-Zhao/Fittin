## Purpose

Define advanced analytics views that help users interpret consistency, volume distribution, and training load over time.

## ADDED Requirements

### Requirement: Consistency Heatmap
The system MUST provide a training consistency explorer that visualizes completed training sessions by day and lets the user switch between recent weekly, monthly, and active-plan-relative weekly views.

The consistency explorer MUST:
- support a week view that summarizes recent training activity by day across consecutive weeks
- support a month view that summarizes training activity across calendar weeks within a month-oriented range
- support a plan-relative view that groups activity into week buckets counted from the start of the active plan
- derive its cells from real completed training records instead of placeholder data
- keep the premium dark visual style while remaining readable on mobile and macOS

#### Scenario: Visualizing consistency by week
- **WHEN** the user views the Advanced Analytics screen and selects the weekly consistency range
- **THEN** they see day cells populated from actual completed training records across recent weeks
- **AND** the screen makes it clear which days contain one or more recorded workouts.

#### Scenario: Visualizing consistency by month
- **WHEN** the user switches the consistency range to month
- **THEN** the screen reorganizes the day cells into a month-oriented overview based on calendar dates
- **AND** the user can still identify which specific dates contain recorded workouts.

#### Scenario: Visualizing consistency from plan start
- **WHEN** the user switches the consistency range to plan-relative weeks
- **THEN** the screen groups days into sequential week buckets counted from the active plan start
- **AND** the labels make it clear which week of the active plan each row or segment represents.

### Requirement: Muscle Volume Distribution
The system MUST visualize weekly set volume per muscle group using horizontal progress bars.

#### Scenario: Checking training balance
- **WHEN** a user reviews the analytics
- **THEN** they see horizontal bars for categories like "Chest", "Lats", "Quads"
- **AND** each bar shows the number of completed sets relative to a target (e.g., 9/10 sets).

### Requirement: Anatomical Load Visualization
The system SHOULD include an anatomical human body diagram where muscle groups are highlighted based on their relative training load in the current training cycle.

#### Scenario: Quick scan of muscle focus
- **WHEN** the user opens the training load tab
- **THEN** an anatomical diagram displays variations in highlight intensity on specific muscle groups reflecting the volume distribution.

### Requirement: Consistency Day Drilldown
The system MUST let the user open the concrete training record for a selected day directly from the consistency explorer.

#### Scenario: Opening a recorded day from the consistency explorer
- **WHEN** the user taps a day that contains one or more completed workouts
- **THEN** the app navigates to the associated training record detail for that date
- **AND** the navigation preserves the user's place in the analytics flow so they can return to the consistency explorer.

### Requirement: Localized Advanced Analytics Copy
The advanced analytics surface MUST present its labels, range controls, helper copy, and consistency annotations in the current app language.

#### Scenario: Viewing advanced analytics in Chinese
- **WHEN** the app language is set to Chinese
- **THEN** the advanced analytics screen renders its titles, range selectors, empty states, and consistency guidance in Chinese
- **AND** switching back to English restores the corresponding English copy without changing the underlying analytics data.
## Requirements
### Requirement: Editable Day Drilldown Records
The system MUST let the user open a recorded day from the analytics drilldown, choose a single workout log from that day, and edit it without breaking the date-based navigation flow.

#### Scenario: User corrects a workout from consistency drilldown
- **WHEN** the user opens a recorded day from analytics and edits one workout log from that day
- **THEN** returning to the day detail shows the corrected workout values
- **AND** the analytics surfaces that derive from the edited log use the updated data on refresh.

