## ADDED Requirements

### Requirement: Broad structured exercise coverage
The built-in catalog SHALL cover common powerlifting, bodybuilding, Olympic lifting, bodyweight, cable, machine, unilateral and conditioning movements with stable bilingual identities, conservative primary/secondary muscles and traceable sources. Special execution characteristics SHALL be explicit bounded fields available to catalog UI and Agent tools.

#### Scenario: Select a unilateral dumbbell variation
- **WHEN** a user or Agent inspects that exercise
- **THEN** equipment, laterality, weight convention, muscle targets and special characteristics are available without inferring them from the display name.

#### Scenario: Load existing records
- **WHEN** an old log is opened after catalog expansion
- **THEN** its stable exercise identity and recorded load are preserved.
