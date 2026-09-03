## ADDED Requirements

### Requirement: Audited patch release publication
The audited layout and stability patch MUST publish application version `1.2.1+25` and tag `v1.2.1` using the stable Android signer, immutable release checksums, the directly hosted Web deployment and first-party Android update metadata. Public metadata MUST remain on the prior verified version until the signed upgrade, Web bootstrap and public readiness checks pass.

#### Scenario: Existing Android user upgrades from v1.2.0
- **WHEN** the signed v1.2.1 APK is installed over the public v1.2.0 application
- **THEN** Android accepts the signer and preserves existing local data, authentication and configuration
- **AND** the application reports version 1.2.1.

#### Scenario: A release gate fails
- **WHEN** CI, signature, checksum, install-over, Web bootstrap or public readiness verification fails
- **THEN** first-party `latest.json` is not advanced
- **AND** the failed deployable remains staged or the previous Web symlink stays active.
