## ADDED Requirements

### Requirement: Agent body metrics use shared validation
Agent-proposed body metrics SHALL require at least one measurement or note and SHALL enforce the same finite ranges as manual entry before creating an approval card.

#### Scenario: Out-of-range body metric
- **WHEN** a proposal supplies an invalid weight, body-fat percentage, or waist measurement
- **THEN** no proposal or persistence write is created and a field-specific validation result is returned
