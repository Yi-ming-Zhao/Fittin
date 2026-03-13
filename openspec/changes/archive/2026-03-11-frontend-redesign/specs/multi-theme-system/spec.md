## ADDED Requirements

### Requirement: Curated Theme Palettes
The system MUST provide a selection of predefined, high-quality color palettes (e.g., Deep Ocean, Minimalist Dark, Sunset Warmth).

#### Scenario: User selects a new theme
- **WHEN** the user selects a new theme palette from the settings menu
- **THEN** the entire application's color scheme updates instantly without requiring a restart.

### Requirement: Theme Persistence
The system MUST save the user's selected theme preference locally and apply it upon subsequent app launches.

#### Scenario: App launch with saved theme
- **WHEN** the user re-opens the app after closing it
- **THEN** the application initializes with the previously selected custom theme rather than the default theme.
