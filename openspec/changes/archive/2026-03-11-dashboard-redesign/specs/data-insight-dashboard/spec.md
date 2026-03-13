## ADDED Requirements

### Requirement: Strength Level Indicator
The system MUST render a circular progress ring to indicate the user's current overall strength level or target completion, using custom drawing techniques with a glow effect.

#### Scenario: User checks current strength level
- **WHEN** the user views the "At a Glance" section
- **THEN** a circular neon-styled progress ring displays a percentage value representing their strength level.

### Requirement: Weekly Progress Bar Chart
The system MUST display a horizontal bar chart summarizing the past 7 days of activity, with the current day visually highlighted.

#### Scenario: User views weekly activity trends
- **WHEN** the user views the "At a Glance" section
- **THEN** a series of vertical bars represent daily activity, and the bar corresponding to "Today" uses a distinct, brighter primary color compared to the others.
