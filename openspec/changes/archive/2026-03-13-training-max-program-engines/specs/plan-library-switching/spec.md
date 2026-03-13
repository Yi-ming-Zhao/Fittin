## MODIFIED Requirements

### Requirement: Active Plan Switching
The system MUST allow the user to switch the active training plan from the plan library, but it MUST collect required training max values before creating the first instance of a TM-driven template.

#### Scenario: User switches to another built-in plan
- **WHEN** the user selects the Jacked & Tan template or GZCLP template from the plan library and taps the switch action
- **THEN** the app either activates an existing instance for that template or, if no instance exists yet, launches training-max setup before creating and activating the new instance.

#### Scenario: User switches back to an existing plan
- **WHEN** the user re-selects a template that already has a saved instance
- **THEN** the app reuses that existing instance instead of resetting the user’s progress.
