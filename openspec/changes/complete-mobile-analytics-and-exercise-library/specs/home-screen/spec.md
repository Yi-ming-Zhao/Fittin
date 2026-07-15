## ADDED Requirements

### Requirement: Viewport-Filling Home Composition
The home dashboard MUST fill the usable mobile viewport through responsive spacing and flexible content while keeping bottom navigation clear on both Android app and mobile web.

#### Scenario: Home opens at different mobile heights
- **WHEN** the home dashboard opens at supported narrow widths with different usable heights
- **THEN** its content reaches the navigation region without a fixed blank footer and remains scrollable when the shorter viewport cannot contain it.

### Requirement: Swipe-Selectable Big Three E1RM
The home e1RM module MUST present Squat, Bench Press, and Deadlift as a horizontally swipeable, page-indicated selection while preserving tap access and localized lift names.

#### Scenario: User swipes the home e1RM module
- **WHEN** the user swipes left or right on the e1RM card
- **THEN** the card transitions to the adjacent Big Three lift and updates value, delta, date, and selection indicator without navigating away.
