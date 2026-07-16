## MODIFIED Requirements

### Requirement: Curated Theme Palettes
The system MUST provide five complete, high-quality palettes named Obsidian Brass, Midnight Cobalt, Bordeaux Velvet, Porcelain Ink, and Espresso Ember. Selecting a palette MUST update backgrounds, surfaces, text, icons, borders, dividers, controls, navigation, charts, anatomy rendering, statuses, and workout feedback immediately without requiring a restart.

#### Scenario: User selects a new theme
- **WHEN** the user selects a palette from the Appearance section
- **THEN** the visible page and all subsequently opened surfaces update in the same frame
- **AND** a selected indicator and accessible state identify the active palette.

### Requirement: Theme Persistence
The system MUST save the selected palette locally and resolve it before the first app frame on subsequent launches. Unknown or retired stored identifiers MUST fall back to Obsidian Brass safely.

#### Scenario: App launch with saved theme
- **WHEN** the user reopens the app with a valid saved palette identifier
- **THEN** the first rendered application frame uses that palette instead of flashing the default.

#### Scenario: App launch with an unknown theme
- **WHEN** local storage contains an unsupported palette identifier
- **THEN** the app starts with Obsidian Brass and remains usable.

## ADDED Requirements

### Requirement: Palette Contrast And Hue Guardrails
Every curated palette MUST meet readable contrast targets for normal text, selected controls, structural lines, chart axes, and on-accent content, and MUST NOT contain cyan or teal theme colors.

#### Scenario: Palette registry is validated
- **WHEN** automated palette validation runs
- **THEN** normal primary text and on-accent content meet at least 4.5:1 contrast
- **AND** secondary large content and important structural emphasis meet at least 3:1
- **AND** no registered user-facing token falls in the prohibited cyan/teal hue range.
