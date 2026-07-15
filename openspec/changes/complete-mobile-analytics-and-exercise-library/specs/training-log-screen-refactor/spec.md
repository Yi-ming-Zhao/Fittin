## ADDED Requirements

### Requirement: Adaptive Card Stack Occupancy
Card recording mode MUST allocate remaining safe viewport height to the current-set card stack and its actions so the recording surface feels intentional on tall phones while compressing without overflow on shorter mobile browsers.

#### Scenario: Logger opens on a tall phone
- **WHEN** card mode has more vertical room than its minimum layout
- **THEN** the active card and stack consume that room through bounded flexible sizing rather than leaving a large empty area below the recording workflow.

#### Scenario: Logger opens in a short browser viewport
- **WHEN** the safe height cannot fit the preferred card size
- **THEN** the card, hints, and actions compact to their minimums and remain usable without covering each other.

## MODIFIED Requirements

### Requirement: Graphical Barbell Plate Breakdown
When plate breakdown is available, the logger MUST show a proportioned mirrored Olympic-style barbell in addition to the numeric loading summary.

The visualization MUST include a center shaft, sleeves, collars, mirrored plates ordered from largest to smallest from the inside outward, plate widths and diameters that remain visually distinguishable, and stable scaling that does not imply a different plate count. The equivalent per-side plate values MUST remain available as localized text and accessibility semantics.

#### Scenario: Viewing a loadable barbell weight
- **WHEN** the current set weight produces a valid plate breakdown
- **THEN** the module renders matching plates on both sleeves with recognizable bar, sleeve, collar, diameter, width, and ordering proportions
- **AND** the exact per-side values remain available as text for precision and accessibility.
