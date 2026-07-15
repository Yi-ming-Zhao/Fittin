## Purpose

Define the PR dashboard experience for surfacing strength trends, milestones, and current estimated performance.

## Requirements

### Requirement: Visual Consistency with Home Dashboard
The progress tracking module MUST utilize the exact design tokens (colors, gradients, glassmorphism intensities) and layering patterns found in the current Home Dashboard. This includes using `onSurface.withValues(alpha: 0.03)` for backgrounds, `onSurface.withValues(alpha: 0.05)` for borders, and `borderRadius: 24-30` for all cards. Navigation tabs and action buttons MUST use frosted-glass effects.

#### Scenario: User opens the PR dashboard
- **WHEN** the user navigates to the PR Dashboard
- **THEN** the screen uses the same glassmorphism, gradient layering, border treatment, and card radius language as the Home Dashboard
- **AND** navigation controls and action affordances keep the same frosted-glass visual family.

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
The dashboard MUST feature three aligned summary cards for Squat, Bench, and Deadlift, and those cards MUST keep a consistent size and layout regardless of whether a lift currently has a delta to display.

#### Scenario: A lift has no previous comparable record
- **WHEN** the user opens the PR Dashboard and one or more primary lifts has no prior record that can be used to calculate a delta
- **THEN** the Squat, Bench, and Deadlift cards still render with matching dimensions
- **AND** the missing delta state does not cause the card grid to collapse or resize unevenly.

#### Scenario: User switches summary metric mode
- **WHEN** the user taps the shared summary toggle on the PR Dashboard
- **THEN** all three primary-lift cards switch together between estimated 1RM and actual PR
- **AND** the selected mode is visually obvious and applied consistently across the full card row.

### Requirement: Progression Visualization
The system MUST provide a focused progression chart that visualizes one selected primary lift at a time instead of merging all primary lifts into one low-context graph.

#### Scenario: User switches the displayed lift
- **WHEN** the user changes the selected lift in the chart controls
- **THEN** the chart updates to show only the chosen lift's progression data
- **AND** the chart preserves explicit x-axis and y-axis labels so the time span and weight scale are readable.

### Requirement: Milestone Preview and History
The PR Dashboard MUST keep its landing-page milestone list concise and provide a dedicated destination for the full milestone history.

#### Scenario: User views the PR dashboard landing page
- **WHEN** the PR Dashboard loads milestone data
- **THEN** the main page shows only the two most recent milestone entries
- **AND** it provides a visible affordance for navigating to the complete milestone history screen.

#### Scenario: User filters full milestone history
- **WHEN** the user opens the milestone history screen
- **THEN** they can filter milestone entries by lift or exercise, by time range, and by PR type
- **AND** the resulting list updates to reflect the selected filters.

### Requirement: Localized PR Dashboard Experience
The PR Dashboard and milestone history flow MUST render using the app's active language setting.

#### Scenario: User views PR dashboard in Chinese
- **WHEN** the app language is set to Chinese
- **THEN** the PR Dashboard header, metric toggle labels, chart labels, milestone copy, filter labels, and empty states are shown in Chinese.

### Requirement: Single-Viewport Mobile PR Overview
The PR Dashboard MUST fit its primary mobile overview in one common phone viewport using a compact Big Three summary region above one dominant progress chart, without requiring the milestone history itself to occupy that viewport.

#### Scenario: PR Dashboard opens on a common phone
- **WHEN** the user opens the dashboard at a supported narrow mobile size
- **THEN** the three PR summaries, selected-lift chart, range control, and milestone preview entry are visible without vertical scrolling.

### Requirement: Swipe-Selectable PR Curve
The detailed PR curve MUST display one exercise at a time and MUST allow horizontal swipes, page indicators, and accessible taps to select the previous or next configured primary exercise.

#### Scenario: User swipes the PR curve
- **WHEN** the selected curve is Squat and the user swipes left
- **THEN** the chart changes to Bench Press, retains the active time range, and updates its labeled axes and selected-point state.

### Requirement: Configurable Milestone Exercises
Milestones MUST default to Squat, Bench Press, and Deadlift and MUST allow the user to select additional or alternative canonical exercises from settings.

#### Scenario: User customizes milestone exercises
- **WHEN** the user saves a milestone selection in settings
- **THEN** future milestone detection and filters use those stable exercise IDs
- **AND** an empty or reset selection restores the Big Three defaults.
