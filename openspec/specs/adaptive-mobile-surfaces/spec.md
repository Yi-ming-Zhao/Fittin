## Purpose

Define how primary mobile surfaces adapt to safe viewport changes across native app and mobile web environments.

## Requirements

### Requirement: Safe Viewport Filling
Primary mobile surfaces MUST size their main content area from the current safe viewport rather than a fixed device height, and MUST account for the app bar, system insets, browser chrome, keyboard, and bottom navigation.

#### Scenario: Same screen opens in Android and mobile web
- **WHEN** a primary screen is rendered in a tall Android app viewport and a shorter mobile browser viewport
- **THEN** its primary content fills the usable height in both environments without an unexplained bottom gap or content hidden behind navigation.

### Requirement: Bounded Responsive Reflow
Viewport filling MUST reflow or scroll secondary content when space is constrained and MUST NOT stretch controls beyond comfortable mobile reading and touch dimensions.

#### Scenario: Browser chrome reduces available height
- **WHEN** the usable viewport becomes shorter while the screen is visible
- **THEN** primary controls remain reachable and secondary content becomes scrollable instead of overflowing or leaving a fixed-height blank region.
