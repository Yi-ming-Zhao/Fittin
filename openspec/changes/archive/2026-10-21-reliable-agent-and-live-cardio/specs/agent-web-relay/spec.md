## MODIFIED Requirements

### Requirement: Bounded streaming forwarding
The relay SHALL cap request bytes, individual response frames, per-user concurrency and user/IP request rate while preserving JSON and event-stream delivery. It SHALL detect first-response and idle timeouts but MUST NOT terminate a productive stream solely for total elapsed time. Authentication, public-target enforcement, credential redaction and disconnect cancellation SHALL remain enforced.

#### Scenario: Streaming provider response
- **WHEN** an allowed provider emits multiple SSE chunks, including beyond five minutes
- **THEN** the relay flushes them progressively and cancels upstream when the client disconnects, without a fixed total-duration cutoff
