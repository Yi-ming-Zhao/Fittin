## MODIFIED Requirements

### Requirement: Bounded streaming Agent runs
The Agent SHALL stream output, support cancellation and resumable interruptions, and complete tasks without fixed total turn, tool, output or elapsed-time quotas. Submit, retry and resume MUST share one controller occupancy guard. Provider truncation SHALL trigger safe continuation, while repeated identical failures without progress SHALL pause resumably. Incomplete tool parameters MUST NOT execute; all writes retain per-operation confirmation and idempotence.

#### Scenario: User cancels a slow response
- **WHEN** the user taps stop while a response is streaming
- **THEN** the network request is cancelled, partial text remains visible, and no unapproved mutation occurs

#### Scenario: A write proposal is generated
- **WHEN** the model calls a proposal-only write tool
- **THEN** the run pauses with one pending approval card until the user decides

#### Scenario: User rapidly retries or resumes
- **WHEN** repeated continuation commands arrive before the busy state renders
- **THEN** only one provider stream and continuation starts

#### Scenario: Long productive task
- **WHEN** a task exceeds eight model turns or twelve tools, or receives a length finish reason
- **THEN** progress persists and the run continues without an output-limit failure or repeated committed mutation

## ADDED Requirements

### Requirement: Stable streaming reading position
The Agent SHALL lazily render stable message identities and coalesce following updates. User scrolling away from the latest output SHALL immediately suspend automatic following. Status, keyboard and Markdown reflow MUST preserve the reading anchor.

#### Scenario: Read earlier output during generation
- **WHEN** the user scrolls upward while tokens continue arriving
- **THEN** the viewport stays anchored and a return-to-latest action appears
