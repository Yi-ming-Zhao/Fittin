## ADDED Requirements

### Requirement: Expanded restrained built-in palette set
The palette registry SHALL include additional light and dark curated schemes with intentional typography and theme-derived strength/cardio series, and no palette role SHALL use cyan or teal.

#### Scenario: User browses built-in palettes
- **WHEN** the Appearance page renders every built-in palette
- **THEN** each preview has a distinct restrained character, readable text, coherent status colors, and visually separable strength/cardio markers

### Requirement: Runtime custom palette resolution
The Material theme and every Fittin component SHALL resolve a selected custom semantic palette through the same token object used for built-in palettes, with no screen-specific fallback colors.

#### Scenario: User activates a custom palette
- **WHEN** the custom palette passes validation and is selected
- **THEN** all open routes update immediately and the selection restores on the next launch
