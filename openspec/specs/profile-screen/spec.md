# profile-screen Specification

## Purpose
TBD - created by archiving change fittin-redesign. Update Purpose after archive.
## Requirements
### Requirement: Consolidated Settings Surface
The system MUST provide a profile screen that consolidates account, language, appearance, workout recording, weight tools, reference material, and visual-detail settings. Appearance MUST be a clearly labeled bilingual section within My/Settings rather than a hidden developer control.

#### Scenario: User opens profile settings
- **WHEN** the user opens the profile screen
- **THEN** the screen shows account status, language selection, the current appearance palette, workout logging preferences, weight-tool access, reference links, and visual adjustment controls in one scrollable settings surface.

### Requirement: Inline Appearance Palette Picker
The My/Settings screen MUST present preview tiles for every curated palette and explain that the choice affects backgrounds, cards, text, lines, charts, and feedback colors.

#### Scenario: User compares palettes
- **WHEN** the user scrolls the Appearance palette row
- **THEN** every palette preview exposes representative canvas, surface, accent, content, and data colors
- **AND** all previews remain reachable at a narrow mobile width.

### Requirement: Supporting Utility Screens
The profile area MUST provide supporting utility flows for account status, weight conversion, and training guidance.

#### Scenario: User opens a profile utility flow
- **WHEN** the user opens account management, the converter, or the training guide from profile settings
- **THEN** the destination surface presents the corresponding sync/account status, weight conversion tools, or structured training-reference content.

### Requirement: Workout Recording Mode Preference
The profile settings screen MUST let the user select card recording or traditional recording, MUST explain the interaction difference, and MUST persist the selection locally.

#### Scenario: Selecting card recording
- **WHEN** the user selects card recording in settings
- **THEN** future and resumed active workouts show the live card stack with swipe gestures.

#### Scenario: Selecting traditional recording
- **WHEN** the user selects traditional recording in settings
- **THEN** future and resumed active workouts show the traditional current-set controls with a centered completion action.

#### Scenario: Restarting the app
- **WHEN** the user relaunches the app after selecting a recording mode
- **THEN** the previously selected recording mode remains active without requiring sign-in.
