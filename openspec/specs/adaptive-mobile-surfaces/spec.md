## Purpose

Define how primary mobile surfaces adapt to safe viewport changes across native app and mobile web environments.

## Requirements

### Requirement: Safe Viewport Filling
Primary mobile surfaces MUST size and distribute their main content from the current safe viewport rather than a fixed device height, accounting for app bars, system insets, browser chrome, keyboards, bottom navigation and the active text scale. Tall viewports MUST use bounded additional spacing or appropriately relaxed modules rather than leaving unexplained gaps or clustering all content around the center. Content that no longer fits MUST remain vertically reachable instead of overflowing.

#### Scenario: Same screen opens in Android and mobile web
- **WHEN** a primary screen is rendered in a tall Android app viewport and a shorter mobile browser viewport
- **THEN** its primary content fills the usable height with balanced bounded rhythm in the tall viewport
- **AND** it remains reachable through one natural vertical scroll in the shorter viewport.

#### Scenario: User enables large text
- **WHEN** a primary or pushed screen is rendered at a system text scale up to 200 percent
- **THEN** text, status and primary actions reflow without clipped content, render overflow or unreachable controls
- **AND** the screen permits vertical scrolling when its content exceeds the safe viewport.

### Requirement: Bounded Responsive Reflow
Viewport filling MUST reflow or scroll secondary content when space is constrained and MUST NOT stretch controls, cards, or gaps beyond comfortable mobile reading and touch dimensions. Every interactive target MUST remain at least 44 logical pixels in both dimensions, including when an inactive navigation label is visually collapsed.

#### Scenario: Browser chrome reduces available height
- **WHEN** the usable viewport becomes shorter while the screen is visible
- **THEN** primary controls remain reachable and secondary content becomes scrollable without horizontal overflow
- **AND** the layout switches to its compact bounded dimensions instead of clipping or retaining tall-screen spacing.

#### Scenario: Narrow six-tab navigation
- **WHEN** the app shell is 320 logical pixels wide
- **THEN** all six destinations keep distinct semantics and at least 44 by 44 logical pixel targets
- **AND** selected and inactive states remain visually distinguishable without horizontal overflow.

### Requirement: Consistent vertical rhythm across all routes
Every reachable main screen, dialog, sheet, and second-level page SHALL use one safe-area owner, shared page gutters, consistent top and bottom clearance, 8 px related-item spacing, and 12–20 px section spacing according to available height.

#### Scenario: Deep page opens on a short phone
- **WHEN** any nested route opens at 390×568 or 320 px width
- **THEN** its header remains visible, content scrolls without clipped controls, no duplicate safe-area gap appears, and related content is not compressed below the shared rhythm.

### Requirement: Route-complete layout regression
The test inventory MUST enumerate every navigable route and hidden subpage and verify 320×568, 390×844, 390×926, large-text, keyboard, and desktop-width states without overflow or undersized interactive controls.

#### Scenario: New subpage is added
- **WHEN** a route is registered without a corresponding layout-test case
- **THEN** the route inventory test fails until coverage is added.
