## ADDED Requirements

### Requirement: Agent relay runtime controls
The custom backend SHALL register the authenticated Agent relay behind existing CORS and rate middleware and SHALL expose dedicated configurable upstream timeout, byte, concurrency, and per-minute limits.

#### Scenario: Backend readiness is independent of provider
- **WHEN** a configured model provider is unavailable
- **THEN** `/readyz` continues to report only Fittin database readiness and Agent requests return a bounded provider-unavailable error
