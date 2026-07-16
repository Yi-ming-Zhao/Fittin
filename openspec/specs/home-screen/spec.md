# home-screen Specification

## Purpose
TBD - created by archiving change fittin-redesign. Update Purpose after archive.
## Requirements
### Requirement: Training-State Home Screen
The system MUST provide a home screen that surfaces the user's current training state, including active-session progress and near-term training context.

#### Scenario: User opens the home screen with an active session
- **WHEN** the user opens the home screen while a workout session is in progress
- **THEN** the screen highlights the in-progress session, current completion state, and the next exercise to resume.

### Requirement: Home Performance Snapshot
The home screen MUST summarize short-horizon performance and activity signals without requiring navigation into analytics screens.

#### Scenario: User scans current performance
- **WHEN** the user opens the home screen
- **THEN** the screen shows cycle progress, a recent e1RM summary, and an activity chart
- **AND** it provides quick actions for switching plans or opening deeper progress views.

### Requirement: Viewport-Filling Home Composition
The Today dashboard MUST fill the usable mobile viewport through a bounded relaxed composition on tall devices and a compact scrollable composition on short devices while keeping bottom navigation clear. The relaxed composition MUST increase meaningful card space and section rhythm rather than inserting one oversized blank region.

#### Scenario: Home opens at different mobile heights
- **WHEN** Today opens at a 390x926 or 390x568 app-shell viewport
- **THEN** the tall viewport renders the relaxed workout, KPI, activity, and quick-action composition with balanced vertical distribution
- **AND** the short viewport renders one vertical compact scroll with every action reachable and no bottom-navigation overlap.

### Requirement: Swipe-Selectable Big Three E1RM
The home e1RM module MUST present Squat, Bench Press, and Deadlift as a horizontally swipeable, page-indicated selection while preserving tap access and localized lift names.

#### Scenario: User swipes the home e1RM module
- **WHEN** the user swipes left or right on the e1RM card
- **THEN** the card transitions to the adjacent Big Three lift and updates value, delta, date, and selection indicator without navigating away.
