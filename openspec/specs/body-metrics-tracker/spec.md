## Purpose

Define the body metrics and progress photo experience for tracking physical changes over time.

## Requirements

### Requirement: Body Metrics Page Hierarchy
The Body Metrics screen MUST present a clear, top-anchored progress hierarchy that adapts spacing and module density to the safe viewport. It MUST prioritize the primary trend module first, then current metric highlights, then measurement history and supporting actions without compressing all content into a dense central cluster.

#### Scenario: Opening the Body Metrics screen with recorded data
- **WHEN** the user opens the Body Metrics screen and measurements exist
- **THEN** the page surfaces a prominent height-aware progress module before secondary metric cards
- **AND** current body metrics reflow into readable supporting summaries
- **AND** measurement history remains visually subordinate and reachable below them.

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

### Requirement: Visual Consistency with Home Dashboard
The Body Metrics module MUST use semantic surface, border, content, chart, and action roles from the selected palette. It MUST preserve the premium minimal hierarchy and readable contrast across both dark and light curated palettes without depending on a literal color or fixed alpha recipe.

#### Scenario: Opening the Body Metrics screen
- **WHEN** the user opens the Body Metrics module in any curated palette
- **THEN** the page feels consistent with the app's premium dashboard language
- **AND** the selected palette distinguishes the primary insight area, supporting metric cards, and action controls
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
The system MUST support body fat, waist circumference, and check-in count in a responsive metric composition. On narrow phones, body fat and waist MUST use two readable columns and Check-ins MUST use a full-width row; at widths of at least 520 px, all three MAY share a row.

#### Scenario: Reviewing body summaries on a narrow phone
- **WHEN** the user views Body Metrics below 520 px wide
- **THEN** body fat and waist values, units, and comparison captions remain readable side by side
- **AND** the Check-ins summary occupies a full-width card below them.

#### Scenario: Reviewing fat loss progress
- **WHEN** current and previous body fat and waist measurements are available
- **THEN** body fat and waist cards show the latest value and change from the previous comparable measurement
- **AND** the responsive layout preserves their supporting visual priority.

#### Scenario: Reviewing a metric without comparison data
- **WHEN** the user has a current waist or body fat value but no prior comparable measurement
- **THEN** the relevant card shows the latest value
- **AND** the card explains that trend comparison is not available yet
- **AND** the page avoids displaying a misleading zero-change or blank delta treatment.

### Requirement: Progress Photo Vault
The system MUST support storing and viewing progress photos, specifically enabling a side-by-side comparison mode between two selected dates.

#### Scenario: Comparing photos
- **WHEN** the user enters the photo comparison mode
- **THEN** the system displays two selected photos labeled "Today" and "[Date]" for visual side-by-side review.

### Requirement: Interactive Weight Trend Axes
The body-weight trend MUST implement the shared interactive chart contract with explicit localized date and weight axes, active kg/lb units, touch-tolerant point selection, and exact measurement details.

#### Scenario: User inspects a historical body weight
- **WHEN** the user taps a point on the body-weight line
- **THEN** the chart highlights that measurement and shows its full date, exact weight, unit, and change from the previous comparable measurement when available.
