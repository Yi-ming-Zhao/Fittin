## ADDED Requirements

### Requirement: Subpage Back Navigation Visibility
The system MUST show a clear back-navigation icon on navigable subpages that are opened from another page and can return to a previous route within the app.

#### Scenario: User opens a pushed subpage
- **WHEN** the user navigates from a primary page to a secondary page such as a detail, settings, editor, or account-related subpage
- **THEN** the destination page shows a visible back icon in its top navigation area
- **AND** the icon is positioned consistently with the app's navigation pattern.

### Requirement: Subpage Back Navigation Behavior
The system MUST wire the subpage back icon to the current navigator stack so the user returns to the immediately previous in-app page.

#### Scenario: User taps the back icon
- **WHEN** the current page can pop a route from the navigator stack
- **THEN** tapping the back icon returns the user to the previous page
- **AND** the app does not create a duplicate route or replace the entire navigation stack.

### Requirement: Root Page Back Icon Exclusion
The system MUST NOT show a misleading back icon on root-level pages that do not have an in-app page to return to.

#### Scenario: User is on a root page
- **WHEN** the page is presented as a root destination in the app shell or initial navigation stack
- **THEN** that page does not show an active back icon
- **AND** the navigation chrome still remains visually balanced.
