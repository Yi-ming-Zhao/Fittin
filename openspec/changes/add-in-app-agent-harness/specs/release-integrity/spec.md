## ADDED Requirements

### Requirement: Signed Agent release publication
The Agent release SHALL use version `1.1.0+21`, the stable Android signer, immutable GitHub release assets and checksums, the first-party Android update manifest, and the directly hosted Web deployment.

#### Scenario: Existing Android user upgrades
- **WHEN** a user installs the v1.1.0 APK over v1.0.13
- **THEN** Android accepts the signer, existing Fittin data remains available, and the application reports version 1.1.0

#### Scenario: Release verification fails
- **WHEN** backend, Web, Android upgrade, checksum, or real-provider canary verification fails
- **THEN** first-party `latest.json` is not advanced and the affected deployable is rolled back or superseded
