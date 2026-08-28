## ADDED Requirements

### Requirement: Durable safe checkpoints
Runs SHALL persist stable run, turn, tool and event identities before publishing state, reconcile committed actions after crashes, and recover interrupted work only after explicit user continuation.

#### Scenario: Crash after commit
- **WHEN** the process ends after an action commits but before its chat result is saved
- **THEN** recovery uses the action ID to report the committed outcome without repeating it

### Requirement: Bounded context and network recovery
The runner SHALL retain complete tool pairs and structured task context within token and byte budgets, support cancellation and safe-boundary steering, and use bounded provider retries and first-byte/idle/total deadlines.

#### Scenario: Long conversation
- **WHEN** context exceeds its configured threshold
- **THEN** old complete turns are summarized without removing the goal or separating calls from results

### Requirement: Local diagnostic privacy
Diagnostics SHALL be bounded to 200 metadata-only events per owner and SHALL exclude prompts, tool results, secrets and body data.

#### Scenario: Export diagnostics
- **WHEN** the user exports diagnostics
- **THEN** only status, identifiers, tool names, durations, usage and stable error codes are included
