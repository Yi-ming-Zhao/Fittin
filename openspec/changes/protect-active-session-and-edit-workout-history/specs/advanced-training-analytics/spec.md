## ADDED Requirements

### Requirement: Editable Day Drilldown Records
The system MUST let the user open a recorded day from the analytics drilldown, choose a single workout log from that day, and edit it without breaking the date-based navigation flow.

#### Scenario: User corrects a workout from consistency drilldown
- **WHEN** the user opens a recorded day from analytics and edits one workout log from that day
- **THEN** returning to the day detail shows the corrected workout values
- **AND** the analytics surfaces that derive from the edited log use the updated data on refresh.
