# plan-library-switching Specification

## Purpose
Define the plan library destination, plan preview behavior, and active-plan switching flow.
## Requirements
### Requirement: Plan Library Catalog
The system MUST provide a dedicated plan library destination that previews all built-in and saved templates, including each plan's localized name, source type, workout count, and active-state indicator.

#### Scenario: User opens the plan tab
- **WHEN** the user selects the second bottom-navigation destination
- **THEN** the app shows a plan library screen listing built-in and user-saved templates with enough summary detail to compare plans before switching
- **AND** that built-in catalog includes GZCLP, Jacked & Tan, and TSA Intermediate Approach 2.0 when their localized content is available.

### Requirement: Active Plan Switching
The system MUST allow the user to switch the active training plan from the plan library, but it MUST collect required training max values before creating the first instance of a TM-driven template.

#### Scenario: User switches to TSA Intermediate
- **WHEN** the user selects the TSA Intermediate template from the plan library and taps the switch action
- **THEN** the app either activates an existing TSA Intermediate instance or, if no instance exists yet, launches training-max setup before creating and activating the new instance.

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

### Requirement: Owner-Scoped Plan Mutations
Edited and imported plan templates MUST be stored for the active account and MUST remain visible through that account's plan queries.

#### Scenario: Signed-in user imports a plan
- **WHEN** a signed-in user imports or edits a plan template
- **THEN** the saved template is owned by that user and appears in the plan library.

### Requirement: Consistent Continuation Target
Home progress and continue-training navigation MUST resolve from one authoritative refreshed plan and instance snapshot and MUST ignore stale asynchronous responses.

#### Scenario: User advances then immediately continues
- **WHEN** a completion advances the active day and the user immediately opens continue training
- **THEN** the session opens the newly active day rather than a stale prior day.
