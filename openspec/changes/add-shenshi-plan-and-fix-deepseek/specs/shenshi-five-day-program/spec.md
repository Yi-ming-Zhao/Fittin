## ADDED Requirements

### Requirement: Faithful five-day built-in template
The application SHALL include a built-in template named 沈师五分划 with chest, back, legs, shoulders, and arms in that order and 4, 4, 5, 5, and 6 exercises respectively. It SHALL preserve the supplied set counts, target repetitions, AMRAP work, unilateral instructions, substitutions, drop-set and 21-repetition notes, rest guidance, and optional abdominal guidance without inventing starting loads or automatic progression.

#### Scenario: User previews the plan
- **WHEN** a user opens 沈师五分划 from the plan library
- **THEN** all five days and original prescriptions are visible and the optional abdominal schedule is included in the plan description without adding a sixth mandatory workout

### Requirement: Non-destructive seed update
The application SHALL add the new template to existing native and Web installations through the shared seed coordinator without switching or resetting an existing active instance.

#### Scenario: Existing installation is upgraded
- **WHEN** an installation already has the earlier built-in templates and an active plan
- **THEN** 沈师五分划 is added exactly once while the selected plan and its progression remain unchanged
