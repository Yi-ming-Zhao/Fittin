## ADDED Requirements

### Requirement: Bilingual Built-in Plan Metadata
The system MUST ship built-in plans with both English and Chinese display content for plan-facing text.

#### Scenario: Built-in plans are seeded
- **WHEN** the app seeds the built-in GZCLP and Jacked & Tan templates
- **THEN** each built-in template includes localized plan names, descriptions, workout titles, day labels, and exercise labels for English and Chinese.

### Requirement: Locale-Aware Plan Rendering
The system MUST resolve built-in plan display text according to the selected app language.

#### Scenario: User previews a built-in plan in Chinese
- **WHEN** the selected app language is Chinese and the user opens a built-in plan preview
- **THEN** the plan name, summary text, workout labels, and exercise names render in Chinese.

#### Scenario: User starts a built-in workout in English
- **WHEN** the selected app language is English and the user starts a built-in workout
- **THEN** the today-workout summary, active session header, and exercise labels render in English.

### Requirement: Plain-Text Fallback for Non-Localized Templates
The system MUST preserve compatibility with templates that do not include bilingual plan content.

#### Scenario: User opens a custom or imported plan without localized fields
- **WHEN** a template lacks localized plan content
- **THEN** the app falls back to the existing plain-text fields for display
- **AND** the plan remains previewable, shareable, and executable.
