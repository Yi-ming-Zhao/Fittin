## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: Bilingual Progress Analytics Copy
The progress analytics experience MUST localize its screen copy, summary labels, formula controls, empty states, and exercise detail labels in both English and Chinese.

#### Scenario: Switching analytics language
- **WHEN** the user changes the app language between English and Chinese
- **THEN** the progress analytics page updates all user-facing analytics copy to the selected language
- **AND** dynamic values such as formula choices, counts, and weight metrics remain correctly formatted for the same underlying data.
