## ADDED Requirements

### Requirement: Canonical Exercise Analytics
Progress analytics MUST group and label data by stable canonical exercise ID while retaining custom exercises and resolving legacy aliases.

#### Scenario: Bilingual logs refer to one lift
- **WHEN** English and Chinese historical names resolve to the same canonical exercise
- **THEN** analytics produces one combined exercise series and displays the current locale's canonical name.

### Requirement: Interactive Progress Lines
Every line chart on progress analytics MUST satisfy the shared interactive chart contract, including explicit axes and selectable exact-value details.

#### Scenario: User inspects an exercise trend
- **WHEN** the user taps a plotted progress point
- **THEN** the screen exposes its exercise, date, metric value, unit, and formula where applicable.
