## ADDED Requirements

### Requirement: Durable approval continuation and account isolation
Approval decisions SHALL become structured tool outcomes in the same run and permit continuation within existing budgets. All asynchronous work SHALL be bound to owner and authentication epoch; switching accounts SHALL cancel old work and replace UI references.

#### Scenario: Confirm then summarize
- **WHEN** a user confirms a pending change
- **THEN** the runner sends the actual committed target and result to the model and continues the original task

#### Scenario: Account changes during execution
- **WHEN** the owner changes while a request or tool is pending
- **THEN** the old run is cancelled and cannot update the new account or its UI
