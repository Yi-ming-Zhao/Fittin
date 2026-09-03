## MODIFIED Requirements

### Requirement: Template Editing Surface
The system MUST provide an in-app editing flow for training templates that allows users to update plan metadata, workout metadata, and ordered workout composition without editing raw JSON. Every icon-only editor action MUST expose a localized unique accessible name, and dense rule fields MUST wrap or stack without overlap at 320 logical pixels and large text.

The editor MUST choose its primary navigation model from template metadata:
- templates with `scheduleMode: linear` MUST expose a direct editor for the reusable workout structure
- templates with `scheduleMode: periodized` MUST let the user choose a concrete week/day slot such as `W1D1` before editing that day's workout

#### Scenario: User edits plan metadata
- **WHEN** a user opens the plan editor for a template
- **THEN** they can modify the template name, description, workout names, day labels, and estimated duration values and save those changes as a template document.

#### Scenario: User reorders workouts
- **WHEN** a user reorders workouts within a template
- **THEN** the saved template preserves the new workout order and uses that order for future scheduling.

#### Scenario: User edits a linear template
- **WHEN** a user opens the editor for a template whose `scheduleMode` is `linear`
- **THEN** the app presents a direct editing surface for the template's reusable workouts without forcing the user to step through every week in the cycle.

#### Scenario: User edits a periodized template
- **WHEN** a user opens the editor for a template whose `scheduleMode` is `periodized`
- **THEN** the app first lets them choose a concrete week/day slot such as `W1D1`
- **AND** editing that slot only changes the selected day's prescription instead of showing the entire multi-month cycle in one long page.

#### Scenario: Assistive user edits a narrow plan
- **WHEN** the editor is used at 320 pixels wide or with large text
- **THEN** reorder, duplicate and delete controls retain distinct localized names and 44-pixel targets
- **AND** progression fields reflow vertically without clipped values or unreachable delete actions.
