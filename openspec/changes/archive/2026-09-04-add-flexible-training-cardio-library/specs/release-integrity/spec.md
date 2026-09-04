## ADDED Requirements

### Requirement: Flexible training and cardio release publication
The `v1.3.0+26` release SHALL be published only after direct domain, storage migration, authentication refresh, Agent mutation, Flutter analyze/test, Android, iOS no-codesign, Web, Go, OpenSpec, and route-complete visual checks pass.

#### Scenario: Existing Android user upgrades from v1.2.1
- **WHEN** the stable signed `v1.3.0` APK is installed over v1.2.1
- **THEN** the package signature and first-install identity remain compatible and plans, progress, logs, body data, Agent history, selected appearance, and authenticated session remain available

#### Scenario: Public boundary check fails
- **WHEN** Web, ready endpoint, signed APK hash, update manifest, or authenticated refresh smoke testing fails
- **THEN** the corresponding deployment is rolled back and `latest.json` is not advanced
