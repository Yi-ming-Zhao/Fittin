## ADDED Requirements

### Requirement: Validated body measurements
The body metric form SHALL await persistence, reject non-finite or implausible values, and report save failures before dismissing.

#### Scenario: Persistence fails
- **WHEN** a valid measurement cannot be saved
- **THEN** the dialog remains recoverable and presents an actionable error

### Requirement: Cross-device progress photos
Progress photos SHALL synchronize stable media identity and authenticated bytes instead of treating another device's local filesystem path as usable.

#### Scenario: Remote-only photo is listed
- **WHEN** a remote progress photo has no local cached file
- **THEN** the client retrieves or marks the media for retrieval without displaying the remote device path
