## ADDED Requirements

### Requirement: Plan Library Catalog
The system MUST provide a dedicated plan library destination that previews all built-in and saved templates, including each plan’s name, source type, workout count, and active-state indicator.

#### Scenario: User opens the plan tab
- **WHEN** the user selects the second bottom-navigation destination
- **THEN** the app shows a plan library screen listing built-in and user-saved templates with enough summary detail to compare plans before switching.

### Requirement: Active Plan Switching
The system MUST allow the user to switch the active training plan from the plan library.

#### Scenario: User switches to another built-in plan
- **WHEN** the user selects the Jacked & Tan template from the plan library and taps the switch action
- **THEN** the app either activates an existing Jacked & Tan instance or creates a new one from that template
- **AND** marks that instance as the current active training plan.

#### Scenario: User switches back to an existing plan
- **WHEN** the user re-selects a template that already has a saved instance
- **THEN** the app reuses that existing instance instead of resetting the user’s progress.

### Requirement: Active Plan Awareness Across Screens
The currently selected plan MUST drive the dashboard and workout entry flow immediately after switching.

#### Scenario: Active plan is changed
- **WHEN** the user switches from GZCLP to Jacked & Tan in the plan library
- **THEN** returning to the dashboard shows the Jacked & Tan workout summary as the current plan context
- **AND** tapping the workout hero launches the Jacked & Tan session rather than the previous plan.
