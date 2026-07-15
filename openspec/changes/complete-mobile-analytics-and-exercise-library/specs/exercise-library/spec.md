## ADDED Requirements

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
