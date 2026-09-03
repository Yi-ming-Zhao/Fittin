## ADDED Requirements

### Requirement: Compact Screen Action Hierarchy
Compact layouts MUST preserve one visually dominant task, keep destructive or secondary controls subordinate, and use responsive wrapping or stacking when translated labels or large text no longer fit in one row. Fixed card heights MUST NOT clip business values or action labels.

#### Scenario: Dense translated content on a short phone
- **WHEN** a data-rich card or action group is shown at 320 by 568 logical pixels in either supported language
- **THEN** its primary value and primary action remain readable and reachable
- **AND** secondary metadata wraps, collapses or moves below without overlapping adjacent content.

#### Scenario: Tall phone has sparse content
- **WHEN** a loading, empty or short-content page is shown on a tall phone
- **THEN** the status appears near the page's established content start and leaves room for the next action
- **AND** it is not centered in a way that disconnects it from the page header or bottom navigation.
