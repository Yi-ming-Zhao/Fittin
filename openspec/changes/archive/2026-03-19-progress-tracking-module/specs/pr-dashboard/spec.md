## ADDED Requirements

### Requirement: Visual Consistency with Home Dashboard
The progress tracking module MUST utilize the exact design tokens (colors, gradients, glassmorphism intensities) and layering patterns found in the current Home Dashboard. This includes using `onSurface.withValues(alpha: 0.03)` for backgrounds, `onSurface.withValues(alpha: 0.05)` for borders, and `borderRadius: 24-30` for all cards. Navigation tabs and action buttons MUST use frosted-glass effects.

### Requirement: E1RM Progression Visualization
The system MUST provide a multi-line chart visualizing the progression of Estimated 1-Rep Max (E1RM) for the "Big Three" lifts (Squat, Bench, Deadlift) over configurable timeframes (Week, Month, Year).

#### Scenario: User toggles chart timeframe
- **WHEN** the user selects "Month" on the PR Dashboard
- **THEN** the chart updates to show daily E1RM peaks for the last 30 days
- **AND** lines for different lifts exhibit distinct but harmonious colors with a subtle neon glow effect.

### Requirement: Automatic PR Achievement Feed
The PR Dashboard MUST include a feed of "Milestones" that automatically records when a user reaches a new lifetime or seasonal PR.

#### Scenario: New PR Detection
- **WHEN** a user logs a set with a calculated E1RM higher than any previous entry
- **THEN** a new achievement card appears in the milestone feed with the label "New Squat PR reached!".

### Requirement: At-a-Glance Strength Cards
The dashboard MUST feature elevated cards showing the current E1RM for primary lifts and the change relative to the previous 30-day average.

#### Scenario: Viewing current strength status
- **WHEN** the user opens the PR Dashboard
- **THEN** they see three prominent cards for Squat, Bench, and Deadlift
- **AND** each card shows the weight (e.g., 425 lbs) and a delta indicator (e.g., +15 lbs).
