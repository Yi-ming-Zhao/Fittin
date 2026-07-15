## ADDED Requirements

### Requirement: Complete Affected-Surface Localization
All user-facing static and dynamic copy introduced or touched by this change MUST render in the active English or Simplified Chinese locale, including chart axes/details, calendar labels, anatomy labels, exercise names, estimate provenance, empty states, and gesture guidance.

#### Scenario: User switches to Chinese
- **WHEN** the active locale becomes Simplified Chinese
- **THEN** every affected screen updates without leftover English labels while dates, numbers, and units remain correctly formatted.

### Requirement: Milestone Exercise Settings
Settings MUST provide a searchable localized multi-select of canonical exercises for milestone tracking, persist stable IDs, and expose a clear reset-to-Big-Three action.

#### Scenario: User changes milestone selection in Chinese
- **WHEN** the user searches, selects, saves, and later reopens milestone exercises in Chinese
- **THEN** the same stable IDs remain selected and display with Chinese canonical names.
