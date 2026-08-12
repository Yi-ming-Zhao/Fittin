## ADDED Requirements

### Requirement: Network-independent gesture commitment
Recognized session gestures SHALL update the local card stack immediately, persist commands in order, and synchronize asynchronously; fast gestures SHALL not be lost because of animation or network timing.

#### Scenario: Rapid valid swipe
- **WHEN** the user performs a fast swipe beyond the velocity or distance threshold
- **THEN** exactly one configured action is committed and the next card becomes interactive without waiting for the network

### Requirement: Visible draft durability
Draft persistence failures SHALL be visible and retryable and SHALL not be silently converted into successful futures.

#### Scenario: Local draft write fails
- **WHEN** persisting the current set fails
- **THEN** the screen retains the user's state, shows a retry action, and prevents a false durability indication
