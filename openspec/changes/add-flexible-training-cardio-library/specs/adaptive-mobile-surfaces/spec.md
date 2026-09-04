## ADDED Requirements

### Requirement: Consistent vertical rhythm across all routes
Every reachable main screen, dialog, sheet, and second-level page SHALL use one safe-area owner, shared page gutters, consistent top and bottom clearance, 8 px related-item spacing, and 12–20 px section spacing according to available height.

#### Scenario: Deep page opens on a short phone
- **WHEN** any nested route opens at 390×568 or 320 px width
- **THEN** its header remains visible, content scrolls without clipped controls, no duplicate safe-area gap appears, and related content is not compressed below the shared rhythm

### Requirement: Route-complete layout regression
The test inventory MUST enumerate every navigable route and hidden subpage and verify 320×568, 390×844, 390×926, large-text, keyboard, and desktop-width states without overflow or undersized interactive controls.

#### Scenario: New subpage is added
- **WHEN** a route is registered without a corresponding layout-test case
- **THEN** the route inventory test fails until coverage is added
