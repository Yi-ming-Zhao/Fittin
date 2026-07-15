## Purpose

Define how the progress analytics screen presents exercise progress, summary insights, and localized analytics copy.

## Requirements

### Requirement: Premium Analytics Presentation
The progress analytics screen MUST present exercise progress, formula controls, and summary metrics inside a premium minimal dark layout with layered hierarchy.

The screen MUST include:
- a clear hero title area
- a distinct formula control module
- grouped summary modules
- lower-emphasis secondary exercise cards beneath the hero content
- varied card hierarchy so not every metric tile is the same size and weight
- localized labels, helper copy, and section headings that follow the current app language

#### Scenario: Opening the analytics tab
- **WHEN** the user opens progress analytics
- **THEN** the page reads as a curated premium insight surface rather than a plain stack of dark list cards
- **AND** the visible copy is rendered in the user's current app language.

### Requirement: Hierarchy Between Highlight Insight And Exercise List
The analytics screen MUST visually separate highlight metrics from the long exercise list so the most important progress signals are visible before deep detail.

#### Scenario: Reviewing progress quickly
- **WHEN** the user wants a fast summary
- **THEN** the page first surfaces the strongest summary insights and only then transitions into the broader exercise-by-exercise list.

### Requirement: Analytics Card Rhythm
The analytics page MUST avoid a repetitive wall of equal dark cards. It SHOULD use a more editorial rhythm through hero cards, summary modules, and calmer secondary exercise blocks.

#### Scenario: Scrolling through analytics
- **WHEN** the user scrolls through the analytics page
- **THEN** the screen maintains visual interest and hierarchy instead of reading as identical dark rectangles stacked vertically.

### Requirement: Bilingual Progress Analytics Copy
The progress analytics experience MUST localize its screen copy, summary labels, formula controls, empty states, and exercise detail labels in both English and Chinese.

#### Scenario: Switching analytics language
- **WHEN** the user changes the app language between English and Chinese
- **THEN** the progress analytics page updates all user-facing analytics copy to the selected language
- **AND** dynamic values such as formula choices, counts, and weight metrics remain correctly formatted for the same underlying data.

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
