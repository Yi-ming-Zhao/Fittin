## MODIFIED Requirements

### Requirement: Body Metrics Page Hierarchy
The Body Metrics screen MUST present a clear, top-anchored progress hierarchy that adapts spacing and module density to the safe viewport. It MUST prioritize the primary trend module first, then current metric highlights, then measurement history and supporting actions without compressing all content into a dense central cluster.

#### Scenario: Opening the Body Metrics screen with recorded data
- **WHEN** the user opens the Body Metrics screen and measurements exist
- **THEN** the page surfaces a prominent height-aware progress module before secondary metric cards
- **AND** current body metrics reflow into readable supporting summaries
- **AND** measurement history remains visually subordinate and reachable below them.

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

### Requirement: Visual Consistency with Home Dashboard
The Body Metrics module MUST use semantic surface, border, content, chart, and action roles from the selected palette. It MUST preserve the premium minimal hierarchy and readable contrast across both dark and light curated palettes without depending on a literal color or fixed alpha recipe.

#### Scenario: Opening the Body Metrics screen
- **WHEN** the user opens the Body Metrics module in any curated palette
- **THEN** the page feels consistent with the app's premium dashboard language
- **AND** the selected palette distinguishes the primary insight area, supporting metric cards, and action controls
- **AND** empty states still feel intentional rather than unfinished.
