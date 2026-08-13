## ADDED Requirements

### Requirement: Six-destination adaptive navigation
The bottom navigation SHALL present Today, Plans, AI, PR, Body, and Me in that order while retaining at least 44 logical pixels of touch height, semantic labels, and a non-overflowing layout on supported phones.

#### Scenario: Narrow phone navigation
- **WHEN** the viewport width is 320 to 390 logical pixels
- **THEN** inactive labels may collapse but all six icons, the active short label, selection semantics, and touch targets remain usable
