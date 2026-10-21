## ADDED Requirements

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
