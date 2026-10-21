## Purpose

Define local, preview-first cardio import and duplicate protection for common fitness export formats.

## Requirements

### Requirement: Standards-based local import
The system SHALL parse GPX, TCX, FIT, and supported CSV exports locally, normalize recognized summaries, and present a preview before creating cardio records.

#### Scenario: Import a running-app GPX file
- **WHEN** a GPX track contains timestamps and route points
- **THEN** the preview shows start time, duration, distance, derived pace, recognized optional metrics, and any missing-data warnings.

#### Scenario: Import a mapped CSV
- **WHEN** column names are not recognized automatically
- **THEN** the user can map date, duration, distance, pace or speed, activity, and optional metrics before previewing records.

### Requirement: Safe import confirmation and deduplication
The system MUST write nothing before confirmation and MUST reject exact source fingerprints and probable duplicates based on start time, duration, and distance.

#### Scenario: Same file is selected twice
- **WHEN** a previously confirmed source file is imported again
- **THEN** the preview marks its records as duplicates and confirmation creates no duplicate rows.

#### Scenario: File is malformed
- **WHEN** a selected file cannot produce a trustworthy time plus duration or distance
- **THEN** the system reports a bounded parsing error without persisting partial records.

### Requirement: Source timing and lap aggregation
Import SHALL preserve distinct elapsed and timer durations when the source supplies them. TCX activity heart-rate summaries SHALL aggregate valid lap summaries using timer-duration weighting and reported maxima, without presenting a first-lap value as a complete activity value. Missing measurements MUST remain absent.

#### Scenario: FIT includes a pause
- **WHEN** a FIT session contains 900 seconds elapsed and 600 seconds timer duration
- **THEN** the preview and persisted record retain both durations and pace uses 600 seconds

#### Scenario: TCX contains different lap intensities
- **WHEN** two laps contain different durations and heart-rate averages and maxima
- **THEN** the activity summary weights averages by lap duration and selects the highest reported maximum

#### Scenario: Missing lap measurement
- **WHEN** not all timed laps have an average heart rate
- **THEN** import does not claim that a partial lap average represents the complete activity
