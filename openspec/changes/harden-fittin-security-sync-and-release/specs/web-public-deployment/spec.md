## ADDED Requirements

### Requirement: Atomic verified web activation
The deployment process SHALL stage builds, run same-origin health/version/asset probes, activate atomically, and restore the prior release if post-activation verification fails.

#### Scenario: Activated build serves stale metadata
- **WHEN** post-activation version metadata does not match the intended release
- **THEN** the script rolls the active symlink back and reports failure

### Requirement: Browser security policy
The public HTTPS service SHALL send transport, content, referrer, and permissions policies compatible with the Flutter application.

#### Scenario: Public page is requested
- **WHEN** a browser loads the application over HTTPS
- **THEN** the response includes the configured security headers and excludes obsolete permissive CORS origins
