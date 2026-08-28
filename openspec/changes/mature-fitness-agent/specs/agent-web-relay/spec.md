## ADDED Requirements

### Requirement: Aligned streaming deadlines and diagnostic errors
The relay SHALL preserve existing authentication and SSRF protections while bounding first-response, idle and total streaming duration, exposing stable termination reasons without provider payloads or credentials.

#### Scenario: Idle upstream stream
- **WHEN** an upstream stops producing data beyond the idle deadline
- **THEN** the relay cancels it and emits a safe typed failure rather than a false successful completion
