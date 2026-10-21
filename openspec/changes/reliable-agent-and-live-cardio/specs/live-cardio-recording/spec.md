## ADDED Requirements

### Requirement: Live sport session
The app SHALL support preparation, start, pause/resume, finish and review for running, walking, cycling and hiking, and timed indoor activities. It SHALL show measured time, distance, pace/speed, location quality, route and laps, with manual laps, optional auto-pause and accidental-touch locking. Missing measurements MUST NOT be fabricated.

#### Scenario: Pause a run
- **WHEN** the user pauses and resumes a run
- **THEN** total and active duration remain distinct and paused displacement is not added to distance

### Requirement: Durable private route capture
Location capture SHALL operate independently of map/network availability, persist owner-scoped timestamped coordinate-system-tagged points and segments, reject implausible jumps and mark recording gaps. Native background capture SHALL occur only during an explicitly started activity. Web SHALL clearly disclose foreground-only tracking. Imported GPX/TCX/FIT routes and laps SHALL be retained when present.

#### Scenario: Process stops while recording
- **WHEN** the app restarts after interrupted capture
- **THEN** it restores persisted measurements and marks the missing interval without inventing a connecting route

### Requirement: Explicit route sharing boundary
Precise routes SHALL remain local by default and SHALL NOT enter ordinary sync, Agent prompts or diagnostics. Export and private cloud sync SHALL each require explicit user action; cloud route chunks MUST enforce ownership and deletion. Online maps SHALL disclose provider traffic and initialize only after required consent.

#### Scenario: Save a private run
- **WHEN** the user saves without choosing route sync
- **THEN** aggregate statistics sync normally and precise points remain local

### Requirement: Field-verified release
The user-approved initial trial SHALL leave online AMap disabled, retain GPS/timing/offline route recording, and disclose that Android 60-minute lock-screen outdoor recording and known-distance comparison await user testing after download. Migration and signed Android upgrade checks SHALL remain required. General availability claims of background recording reliability SHALL require the actual field test. Unsigned iOS build success MUST NOT be reported as physical-device tracking verification.

#### Scenario: Field test is unavailable
- **WHEN** automated tests pass but physical recording evidence is missing
- **THEN** the explicitly authorized trial may publish after the remaining release gates pass, with field validation clearly marked outstanding and online AMap disabled
