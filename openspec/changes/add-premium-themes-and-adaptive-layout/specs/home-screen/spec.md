## MODIFIED Requirements

### Requirement: Viewport-Filling Home Composition
The Today dashboard MUST fill the usable mobile viewport through a bounded relaxed composition on tall devices and a compact scrollable composition on short devices while keeping bottom navigation clear. The relaxed composition MUST increase meaningful card space and section rhythm rather than inserting one oversized blank region.

#### Scenario: Home opens at different mobile heights
- **WHEN** Today opens at a 390x926 or 390x568 app-shell viewport
- **THEN** the tall viewport renders the relaxed workout, KPI, activity, and quick-action composition with balanced vertical distribution
- **AND** the short viewport renders one vertical compact scroll with every action reachable and no bottom-navigation overlap.
