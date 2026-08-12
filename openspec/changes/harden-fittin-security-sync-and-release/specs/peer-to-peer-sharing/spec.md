## ADDED Requirements

### Requirement: Bounded validated template import
Shared template decoding SHALL cap encoded and decompressed sizes and SHALL run domain validation before any template is persisted.

#### Scenario: Compressed payload expands beyond limit
- **WHEN** a shared code decompresses beyond the configured maximum
- **THEN** import stops with a validation error and does not allocate or persist the complete payload
