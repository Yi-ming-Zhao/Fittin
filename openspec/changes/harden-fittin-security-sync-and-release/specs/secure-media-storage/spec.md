## ADDED Requirements

### Requirement: Owner-scoped progress media
The backend SHALL derive the media owner from the authenticated session, SHALL reject invalid media identifiers and oversized or non-image uploads, and SHALL only return media owned by that user.

#### Scenario: Forged ownership is rejected
- **WHEN** an authenticated user supplies another user's identifier or a traversal-like photo identifier
- **THEN** the server rejects the request without reading or writing another user's storage

#### Scenario: Photo is restored on another device
- **WHEN** a signed-in device synchronizes a photo row whose media bytes are not available locally
- **THEN** the client downloads the authenticated media, stores it locally, and preserves a retryable state on failure
