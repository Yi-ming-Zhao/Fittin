## MODIFIED Requirements

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

## ADDED Requirements

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
