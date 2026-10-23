## MODIFIED Requirements

### Requirement: Personal opt-in online area map
The app SHALL offer a default-off AMap area image separate from offline route capture, without requiring user Key entry. Each enable action SHALL require sign-in and explicit confirmation that a single requested point passes through Fittin to AMap without storage. The configured Key MUST remain backend-only and never ship in public builds or enter sync/logs. Refresh SHALL be manual and limited to one in-flight request; provider errors SHALL be redacted and leave recording unaffected. Actual provider verification SHALL be reported separately from mocked checks.

#### Scenario: Map is not enabled
- **WHEN** the activity page or review opens without explicit consent
- **THEN** no map request is sent and the offline route remains available

#### Scenario: Personal map fails
- **WHEN** the configured Key, quota or network prevents loading
- **THEN** a safe error and retry/close controls appear without changing recording or requesting Key input

#### Scenario: Account changes during map loading
- **WHEN** the account changes before the response completes
- **THEN** old map data is discarded and stale consent cannot initiate requests for the new account

### Requirement: Field-verified release
The user-approved trial SHALL retain GPS/timing/offline route recording and disclose that Android 60-minute lock-screen outdoor recording and known-distance comparison await user testing. The default-off configured map preview SHALL require authentication and explicit position-sharing consent for authorized personal use. Migration and signed Android upgrade checks SHALL remain required. General background reliability claims SHALL require actual field tests; unsigned iOS builds MUST NOT be described as physical-device verification.

#### Scenario: Field test is unavailable
- **WHEN** automated checks pass but physical recording evidence is missing
- **THEN** the approved trial may release after remaining gates pass, with field validation outstanding and maps disabled until user consent
