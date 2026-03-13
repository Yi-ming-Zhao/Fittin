# plan-library-switching Specification

## Purpose
Define the plan library destination, plan preview behavior, and active-plan switching flow.

## Requirements
### Requirement: Plan Library Catalog
The system MUST provide a dedicated plan library destination that previews all built-in and saved templates, including each plan’s localized name, source type, workout count, and active-state indicator.

#### Scenario: User opens the plan tab
- **WHEN** the user selects the second bottom-navigation destination
- **THEN** the app shows a plan library screen listing built-in and user-saved templates with enough summary detail to compare plans before switching.
- **AND** built-in plan text is rendered using the selected app language when localized content is available.

### Requirement: Active Plan Switching
The system MUST allow the user to switch the active training plan from the plan library, but it MUST collect required training max values before creating the first instance of a TM-driven template.

#### Scenario: User switches to another built-in plan
- **WHEN** the user selects the Jacked & Tan template or GZCLP template from the plan library and taps the switch action
- **THEN** the app either activates an existing instance for that template or, if no instance exists yet, launches training-max setup before creating and activating the new instance.

#### Scenario: User switches back to an existing plan
- **WHEN** the user re-selects a template that already has a saved instance
- **THEN** the app reuses that existing instance instead of resetting the user’s progress.

### Requirement: Active Plan Awareness Across Screens
The currently selected plan MUST drive the dashboard and workout entry flow immediately after switching.

#### Scenario: Active plan is changed
- **WHEN** the user switches from GZCLP to Jacked & Tan in the plan library
- **THEN** returning to the dashboard shows the Jacked & Tan workout summary as the current plan context
- **AND** tapping the workout hero launches the Jacked & Tan session rather than the previous plan.

#### Scenario: Active plan text follows app language
- **WHEN** the selected app language changes after a plan is already active
- **THEN** the plan library and dashboard refresh their built-in plan labels using the new language
- **AND** the active plan instance remains the same.
