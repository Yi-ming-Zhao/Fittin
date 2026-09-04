## ADDED Requirements

### Requirement: Mixed training timeline
The training trend SHALL combine strength and cardio activity in one chronological view while using distinct theme-derived colors, shapes, labels, and legends for the two modalities.

#### Scenario: Week contains strength and running
- **WHEN** the selected period includes both completed strength logs and cardio records
- **THEN** the chart distinguishes them without relying on color alone and exposes each activity's type and value to accessibility semantics

### Requirement: Modality-appropriate summaries
Strength trends SHALL retain volume and estimated-strength metrics, while cardio trends SHALL summarize duration, distance, pace or speed, and frequency using explicit units and time ranges.

#### Scenario: User selects cardio
- **WHEN** the user filters the trend to cardio
- **THEN** strength-only metrics disappear and the summary reports cardio duration, distance, session count, and an activity-appropriate pace or speed
