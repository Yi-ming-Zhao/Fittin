## ADDED Requirements

### Requirement: In-App Set Type Guide
The system MUST bundle an in-app markdown guide that explains supported training set categories and when each category is typically used.

The guide MUST cover at least `straight_set`, `top_set`, `backoff_set`, `amrap_set`, and `warmup_set`.

#### Scenario: User opens the guide
- **WHEN** the user navigates to the set type guide from the profile/settings area
- **THEN** the app displays a readable markdown document describing the supported set categories and their intended use.

### Requirement: Set Type Selection Guidance
The system MUST explain how a user should choose a set category when editing a plan instead of treating all sets as the same generic structure.

#### Scenario: User wants to understand top set vs straight set
- **WHEN** the user reads the bundled guide
- **THEN** they see plain-language guidance about the difference between focused heavy sets, repeated working sets, backoff sets, and AMRAP sets.

### Requirement: Bilingual Guide Availability
The system MUST provide the set type guide in the app’s supported interface languages.

#### Scenario: User changes app language
- **WHEN** the user switches between English and Chinese
- **THEN** opening the set type guide shows the markdown content in the selected app language.
