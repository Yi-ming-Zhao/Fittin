## Purpose

Define the versioned canonical exercise catalog, bilingual identities, deterministic alias resolution, and evidence metadata used throughout the app.

## Requirements

### Requirement: Canonical Exercise Identity
The system MUST maintain powerlifting, assistance, and bodybuilding exercises in one versioned library using stable exercise IDs independent of translated display names.

Each exercise MUST define confirmed English and Simplified Chinese names, searchable aliases, movement pattern, equipment, primary and secondary muscles, and an optional Squat, Bench, or Deadlift anchor relationship.

#### Scenario: Plan and history use different names for the same exercise
- **WHEN** a plan says `Back Squat`, an older log says `深蹲`, and both resolve to the canonical back-squat aliases
- **THEN** the system treats them as one exercise identity while displaying the active locale's canonical name.

### Requirement: Deterministic Alias Resolution
Exercise resolution MUST normalize case, spacing, punctuation, common abbreviations, and known Chinese/English aliases deterministically and MUST preserve an explicit custom-exercise fallback when no canonical match exists.

#### Scenario: Unknown custom movement is imported
- **WHEN** an imported plan contains a movement that has no library ID or recognized alias
- **THEN** the system creates or retains a stable custom identity instead of silently mapping it to an unrelated exercise.

### Requirement: Versioned Evidence Metadata
Recommended anchor ratios and taxonomy metadata MUST carry a library version, source category, and confidence level so recommendations can be revised without changing historical recorded loads.

#### Scenario: A recommendation changes in a later library version
- **WHEN** the bundled ratio for an assistance exercise is revised
- **THEN** prior workout records keep their original values and new estimates identify the newer library version used.

### Requirement: Tagged exercise catalog
The exercise library SHALL expose normalized movement, primary muscle, secondary muscle, equipment, load semantics, and user tags for every selectable exercise and SHALL support localized search and multi-tag filtering.

#### Scenario: Filter back dumbbell movements
- **WHEN** the user filters by back and dumbbell
- **THEN** the catalog shows matching exercises with their primary muscle and equipment tags without duplicating aliases.

### Requirement: User exercise definitions
The system SHALL let users create, revise, duplicate, and soft-delete owner-scoped custom exercises using the supported tags and load semantics while built-in definitions remain immutable.

#### Scenario: User customizes a built-in exercise
- **WHEN** the user edits a built-in definition
- **THEN** the system saves a custom copy with a stable custom ID and retains the built-in entry.

#### Scenario: Custom exercise is referenced by history
- **WHEN** a custom exercise used by a workout log is deleted
- **THEN** existing history keeps its recorded name and ID while the exercise disappears from future selection.
