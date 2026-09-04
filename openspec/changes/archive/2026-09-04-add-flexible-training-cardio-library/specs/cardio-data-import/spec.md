## ADDED Requirements

### Requirement: Standards-based local import
The system SHALL parse GPX, TCX, FIT, and supported CSV exports locally, normalize recognized summaries, and present a preview before creating cardio records.

#### Scenario: Import a running-app GPX file
- **WHEN** a GPX track contains timestamps and route points
- **THEN** the preview shows start time, duration, distance, derived pace, recognized optional metrics, and any missing-data warnings

#### Scenario: Import a mapped CSV
- **WHEN** column names are not recognized automatically
- **THEN** the user can map date, duration, distance, pace or speed, activity, and optional metrics before previewing records

### Requirement: Safe import confirmation and deduplication
The system MUST write nothing before confirmation and MUST reject exact source fingerprints and probable duplicates based on start time, duration, and distance.

#### Scenario: Same file is selected twice
- **WHEN** a previously confirmed source file is imported again
- **THEN** the preview marks its records as duplicates and confirmation creates no duplicate rows

#### Scenario: File is malformed
- **WHEN** a selected file cannot produce a trustworthy time plus duration or distance
- **THEN** the system reports a bounded parsing error without persisting partial records
