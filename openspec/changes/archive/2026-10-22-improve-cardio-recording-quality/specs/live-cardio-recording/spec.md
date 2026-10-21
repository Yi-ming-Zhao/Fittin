## ADDED Requirements

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
