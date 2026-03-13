## MODIFIED Requirements

### Requirement: Strength Level Indicator
The system MUST replace the placeholder third-tab insight widgets with a progress analytics destination focused on logged training progress rather than a static decorative strength ring.

#### Scenario: User opens the third navigation tab
- **WHEN** the user selects the third bottom-navigation destination
- **THEN** the app opens the progress analytics screen as the primary content for that tab
- **AND** the screen is populated from workout-history-derived analytics instead of placeholder demo visuals.

### Requirement: Weekly Progress Bar Chart
The system MUST treat historical activity summaries as one component of the broader analytics destination rather than as the sole purpose of the third tab.

#### Scenario: User reviews recent activity in analytics
- **WHEN** the analytics screen includes recent activity context
- **THEN** the app may render weekly activity summaries alongside strength progress metrics
- **AND** those summaries support, but do not replace, exercise-level progress analysis.
