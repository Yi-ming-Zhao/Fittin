## ADDED Requirements

### Requirement: Canonical Exercise Resolution In Plans
The plan parser and runtime MUST resolve every exercise to a canonical or stable custom exercise identity before prescriptions, training-max mappings, analytics, or localization are applied.

#### Scenario: Built-in bilingual plan is started
- **WHEN** plan content names a known exercise through an English name, Chinese name, or alias
- **THEN** the instance stores the same canonical exercise ID and displays its name in the active locale.

### Requirement: Missing Starting Load Estimation
When a plan intentionally omits a starting load, instance creation MUST calculate a conservative suggested load from the exercise performance profile or canonical Big Three anchor metadata, target reps, equipment increment, and confidence adjustment.

#### Scenario: Starting a plan with an assistance movement
- **WHEN** an assistance movement has no explicit plan load and the user has a valid anchor-lift profile
- **THEN** the engine creates a reviewable estimate with value, unit, formula, anchor, ratio, confidence, and library version
- **AND** user confirmation or editing does not change the underlying recommendation metadata.

#### Scenario: Plan already specifies a load
- **WHEN** an exercise has an explicit plan or user-authored starting load
- **THEN** the engine preserves that load and does not replace it with an automatic estimate.
