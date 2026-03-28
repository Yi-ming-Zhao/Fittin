## ADDED Requirements

### Requirement: Body Metrics Page Hierarchy
The Body Metrics screen MUST present a clear information hierarchy that reads as a progress dashboard rather than a collection of oversized placeholder cards. The screen MUST prioritize the primary trend module first, then current metric highlights, then measurement history and supporting actions.

#### Scenario: Opening the Body Metrics screen with recorded data
- **WHEN** the user opens the Body Metrics screen and measurements exist
- **THEN** the page surfaces a prominent primary progress module before secondary metric cards
- **AND** current body metrics appear as supporting summary content rather than dominating the entire viewport
- **AND** the measurement history appears as a lower-priority review section beneath the summary modules.

### Requirement: Actionable Empty And Partial States
The Body Metrics screen MUST distinguish between empty, partial, and populated measurement states and MUST guide the user toward the next meaningful action in each case.

#### Scenario: No body measurements recorded
- **WHEN** the user opens the Body Metrics screen with no measurements recorded
- **THEN** the page explains that no body measurements are available yet
- **AND** the page presents a clear measurement-entry call-to-action
- **AND** the page avoids rendering large empty metric cards that imply missing or broken content.

#### Scenario: Incomplete measurement recorded
- **WHEN** the latest measurement contains only some tracked fields such as weight without waist or body fat
- **THEN** the page shows the available values
- **AND** missing metrics are labeled as not yet recorded instead of appearing as ambiguous placeholders
- **AND** the page offers a clear path to add a more complete measurement.

### Requirement: Measurement Log Context
The Body Metrics screen MUST present the measurement log as contextual support for the summary modules, including enough metadata for the user to understand recency and review prior entries.

#### Scenario: Reviewing historical entries
- **WHEN** the user scrolls to the measurement log
- **THEN** each entry shows its recorded date
- **AND** the list is visually subordinate to the primary summary modules
- **AND** the log remains usable as a review and cleanup surface for prior measurements.

## MODIFIED Requirements

### Requirement: Visual Consistency with Home Dashboard
The Body Metrics module MUST follow the Premium Glassmorphism style: using `onSurface.withValues(alpha: 0.03)` base layers, thin borders, and vibrant primary-color highlights for primary call-to-actions.

The screen MUST preserve the premium minimal dark presentation while still maintaining clear hierarchy, readable contrast, and obvious action affordances across empty, partial, and populated states.

#### Scenario: Opening the Body Metrics screen
- **WHEN** the user opens the Body Metrics module
- **THEN** the page feels consistent with the app's premium dashboard language
- **AND** the visual emphasis helps the user distinguish the primary insight area, supporting metric cards, and action controls
- **AND** empty states still feel intentional rather than unfinished.

### Requirement: Historical Body Metric Charting
The system MUST provide line charts for tracking changes in body weight over time, appearing prominently in the Body Metrics module.

The chart module MUST act as the primary progress surface when weight data exists and MUST provide contextual empty-state guidance when trend data is unavailable.

#### Scenario: User records weight
- **WHEN** the user adds a new weight entry of 78.5 kg
- **THEN** the historical line graph updates immediately to include the new data point
- **AND** the primary display updates to the latest value
- **AND** the chart remains visually prioritized above secondary metric summaries.

#### Scenario: No weight trend available
- **WHEN** the user opens the Body Metrics screen without any recorded weight values
- **THEN** the chart area explains that trend data is not available yet
- **AND** the user is directed toward recording a first or more complete measurement
- **AND** the page does not collapse into a visually empty hero region.

### Requirement: Metric Grid Comparison
The system MUST support tracking of secondary body metrics (Body Fat %, Waist Circumference) in a tiled grid layout that emphasizes the latest measurement context and the delta from the previous comparable measurement.

The metric tiles MUST clearly communicate whether a metric has a current value, a previous comparison, or no recorded value yet.

#### Scenario: Reviewing fat loss progress
- **WHEN** the user views the Body Metrics screen with current and previous body fat and waist measurements available
- **THEN** cards for "Body Fat" and "Waist" show the latest percentage or measurement
- **AND** each card shows the change from the previous comparable measurement
- **AND** the cards read as supporting highlights rather than oversized empty canvases.

#### Scenario: Reviewing a metric without comparison data
- **WHEN** the user has a current waist or body fat value but no prior comparable measurement
- **THEN** the relevant card shows the latest value
- **AND** the card explains that trend comparison is not available yet
- **AND** the page avoids displaying a misleading zero-change or blank delta treatment.
