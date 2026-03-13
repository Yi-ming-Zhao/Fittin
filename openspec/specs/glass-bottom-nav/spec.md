# glass-bottom-nav Specification

## Purpose
TBD - created by archiving change dashboard-redesign. Update Purpose after archive.
## Requirements
### Requirement: Floating Frosted Navigation Bar
The system MUST provide a persistent bottom navigation bar that floats above the content and features a frosted glass (blur) transparency effect.

#### Scenario: User scrolls long dashboard content
- **WHEN** the user scrolls the dashboard vertically
- **THEN** the underlying content is visible as a blurred layer beneath the floating bottom navigation bar.

### Requirement: Navigation Tab Selection
The system MUST indicate the currently selected active tab using an accent color and an optional glowing dot indicator.

#### Scenario: User identifies current navigation context
- **WHEN** the Home tab is selected
- **THEN** the Home icon is colored with the primary theme color and has a small glowing indicator beneath it, while other tabs remain muted.

### Requirement: Plan Library Navigation Destination
The system MUST make the second bottom-navigation item open the plan library and switching experience.

#### Scenario: User taps the second tab
- **WHEN** the user taps the second item in the floating bottom navigation bar
- **THEN** the main app content switches to the plan library destination
- **AND** the second tab is rendered as the active navigation context.
