## MODIFIED Requirements

### Requirement: Gesture-First Set Logging
The workout logger MUST preserve a gesture-first, low-friction flow for reps and weights without requiring keyboard input during a normal workout.

On the refactored training log screen, the primary visible controls MUST be limited to increment reps, decrement reps, weight adjustment, direct weight entry, optional RPE editing, set completion, and current-set cancellation.

#### Scenario: Completing a working set
- **WHEN** the user records a set
- **THEN** they can adjust reps and weight using large touch targets or gestures instead of opening a text field.

#### Scenario: Jumping to an exact weight
- **WHEN** the user needs to enter a specific weight quickly
- **THEN** they can tap the current weight display and type the exact value without leaving the compact logger flow.

## ADDED Requirements

### Requirement: Directional Card Resolution Gestures
In card recording mode, the logger MUST resolve a dominant left swipe as completion and a dominant downward swipe as cancellation, with no data mutation until the gesture passes its release threshold.

#### Scenario: Completing by swiping left
- **WHEN** the user drags the current set card predominantly left beyond the completion threshold and releases
- **THEN** the set is recorded as complete and the next unresolved card becomes current.

#### Scenario: Cancelling by swiping down
- **WHEN** the user drags the current set card predominantly down beyond the cancellation threshold and releases
- **THEN** the set is marked cancelled rather than completed
- **AND** the next unresolved card becomes current
- **AND** the cancelled set cannot satisfy progression success criteria.

#### Scenario: Dragging in an unsupported direction
- **WHEN** the user drags predominantly right or up and releases
- **THEN** the card returns to rest and the workout draft remains unchanged.
