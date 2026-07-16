## Purpose

Define how primary mobile surfaces adapt to safe viewport changes across native app and mobile web environments.

## Requirements

### Requirement: Safe Viewport Filling
Primary mobile surfaces MUST size and distribute their main content from the current safe viewport rather than a fixed device height, accounting for app bars, system insets, browser chrome, keyboards, and bottom navigation. Tall viewports MUST use bounded additional spacing or appropriately relaxed modules rather than leaving unexplained gaps or clustering all content around the center.

#### Scenario: Same screen opens in Android and mobile web
- **WHEN** a primary screen is rendered in a tall Android app viewport and a shorter mobile browser viewport
- **THEN** its primary content fills the usable height with balanced bounded rhythm in the tall viewport
- **AND** it remains reachable through one natural vertical scroll in the shorter viewport.

### Requirement: Bounded Responsive Reflow
Viewport filling MUST reflow or scroll secondary content when space is constrained and MUST NOT stretch controls, cards, or gaps beyond comfortable mobile reading and touch dimensions.

#### Scenario: Browser chrome reduces available height
- **WHEN** the usable viewport becomes shorter while the screen is visible
- **THEN** primary controls remain reachable and secondary content becomes scrollable without horizontal overflow
- **AND** the layout switches to its compact bounded dimensions instead of clipping or retaining tall-screen spacing.
