# live-cardio-recording Specification

## Purpose
Define explicit sport recording, durable private routes and honest platform/field-validation boundaries.

## Requirements

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
The user-approved trial SHALL retain GPS/timing/offline route recording and disclose that Android 60-minute lock-screen outdoor recording and known-distance comparison await user testing after download. Shared-key online AMap SHALL remain disabled; a default-off personal-key area preview SHALL be available only after explicit position-sharing consent for the user's authorized use. Migration and signed Android upgrade checks SHALL remain required. General availability claims of background recording reliability SHALL require the actual field test. Unsigned iOS build success MUST NOT be reported as physical-device tracking verification.

#### Scenario: Field test is unavailable
- **WHEN** automated tests pass but physical recording evidence is missing
- **THEN** the explicitly authorized trial may publish after the remaining release gates pass, with field validation clearly marked outstanding and online AMap disabled by default

### Requirement: Continuous stationary fixes
The recorder SHALL distinguish an ongoing stream of valid stationary fixes from a true reception gap. Optional automatic pause SHALL remain paused until measured movement resumes; missing signal MUST NOT fabricate distance.

#### Scenario: Stationary fixes arrive every ten seconds
- **WHEN** the stationary phone continues receiving valid fixes for sixty seconds with auto-pause enabled
- **THEN** the recorder enters and remains automatically paused rather than repeatedly resetting stationary detection as a signal gap

#### Scenario: Prolonged stationary capture followed by movement
- **WHEN** valid stationary fixes arrive continuously before an abrupt jump or real movement resumes
- **THEN** jump detection and current speed use adjacent valid fixes, without diluting speed by stationary minutes
- **AND** split interpolation does not backdate a resumed crossing into the detected stop, while continuous sub-threshold walking retains its time

### Requirement: Useful split and source review
Live and saved activity views SHALL show split-specific duration, distance and pace or cycling speed, with units and missing-data placeholders. Saved review SHALL distinguish available elapsed and timer duration and identify recorded/imported/manual provenance without fabricating sensor measurements.

#### Scenario: Unequal lap distances
- **WHEN** a user reviews a manual partial lap and an automatic split
- **THEN** each row uses its own distance and duration to calculate pace and labels its source without claiming every row is a full kilometre

#### Scenario: Narrow mobile screen
- **WHEN** split review is displayed at 320 pixels with large text or English labels
- **THEN** values remain readable and do not overflow horizontally

### Requirement: Background checkpoint continuity
Native recording SHALL retain its location subscription when hidden or screen-locked, checkpoint on background entry and from location callbacks independently of UI timers, and refresh on foreground return. Start and resume SHALL only initiate location capture while the app is foregrounded. Notification and power restrictions SHALL be discoverable without forcing permission or battery exemptions. Pausing or finishing SHALL stop capture; process interruption SHALL remain explicit on recovery.

#### Scenario: Hide an active run
- **WHEN** a native run enters hidden/paused state and location fixes continue
- **THEN** the same subscription remains active and new points are persisted without requiring UI timer callbacks

#### Scenario: Start finishes asynchronously after backgrounding
- **WHEN** preparation or a permission request completes after the application has left the foreground
- **THEN** no new background location service is started and the user can retry in the foreground

#### Scenario: Notification denied
- **WHEN** Android notifications are disabled
- **THEN** recording is not described as failed solely for that reason and the UI offers explicit settings guidance

### Requirement: Readable dedicated control lock
Locking SHALL preserve live time, distance, pace and location information while disabling content interactions and navigation. Only a long press on the dedicated bottom unlock control SHALL unlock; unrelated screen gestures and short taps MUST NOT unlock. The unlock control SHALL remain reachable at 320px width and expose accessible long-press semantics.

#### Scenario: Touch locked metrics
- **WHEN** the user taps, swipes or long-presses displayed metrics
- **THEN** measurements remain visible and the controls remain locked

#### Scenario: Hold dedicated unlock button
- **WHEN** the user long-presses the dedicated unlock button
- **THEN** normal controls return without pausing or changing the recorded activity

### Requirement: Personal opt-in online area map
The app SHALL offer a default-off, personal-key AMap area image separate from offline route capture. Each enable action SHALL require position-sharing confirmation; only the requested point SHALL be sent, using provider GPS coordinate conversion. Keys SHALL remain in session memory, be cleared on account changes, and never ship in public builds or enter sync/logs. Refresh SHALL be manual and limited to one in-flight request; provider errors SHALL be redacted and leave recording unaffected. Actual provider-key verification SHALL be reported separately from mocked protocol checks.

#### Scenario: Map is not enabled
- **WHEN** the activity page or review is opened without explicit map consent
- **THEN** no request is sent to AMap and the offline route remains available

#### Scenario: Personal map fails
- **WHEN** the user consents but the key, quota or network prevents map loading
- **THEN** a safe error and retry/close controls appear without changing recording or exposing the key

#### Scenario: Account changes during map loading
- **WHEN** the current account changes before the map response completes
- **THEN** the old map and key are not exposed to the new account and no second provider request is initiated after cancellation
