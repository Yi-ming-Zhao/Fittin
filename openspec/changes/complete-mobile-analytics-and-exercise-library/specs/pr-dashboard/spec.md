## ADDED Requirements

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
