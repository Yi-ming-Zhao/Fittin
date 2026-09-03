## MODIFIED Requirements

### Requirement: Bounded streaming Agent runs
The Agent SHALL stream visible output, support cancellation and retry, preserve interrupted user input, and stop after eight model turns or twelve tool calls. Submit, retry and resume commands MUST share one controller-side occupancy guard so rapid repeated controls cannot launch concurrent provider runs for the same conversation.

#### Scenario: User cancels a slow response
- **WHEN** the user taps stop while a response is streaming
- **THEN** the network request is cancelled, partial text remains visible, and no local mutation occurs.

#### Scenario: A write proposal is generated
- **WHEN** the model calls a proposal-only write tool
- **THEN** the run pauses with one pending approval card and performs no further model or write calls until the user decides.

#### Scenario: User rapidly retries or resumes
- **WHEN** several retry or resume commands arrive before the first command yields a visible busy state
- **THEN** the controller starts one continuation and one provider stream
- **AND** all duplicate commands observe that same in-flight operation without creating another run identifier.
