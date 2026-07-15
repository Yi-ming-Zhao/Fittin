## MODIFIED Requirements

### Requirement: Gesture-First Set Logging
The workout logger MUST preserve a gesture-first, low-friction flow for reps and weights without requiring keyboard input during a normal workout.

On the refactored training log screen, the primary visible controls MUST be limited to increment reps, decrement reps, weight adjustment, direct weight entry, optional RPE editing, set completion, current-set skipping, and four-way card gestures in card mode.

#### Scenario: Completing a working set
- **WHEN** the user records a set
- **THEN** they can adjust reps and weight using large touch targets and complete it with an upward card gesture or centered tap action without opening a text field.

#### Scenario: Jumping to an exact weight
- **WHEN** the user needs to enter a specific weight quickly
- **THEN** they can tap the current weight display and type the exact value without leaving the compact logger flow.

#### Scenario: Navigating and resolving sets by gesture
- **WHEN** the user uses card mode
- **THEN** left and right gestures navigate next and previous sets
- **AND** up and down gestures complete and skip the current set.

### Requirement: Focused Single-Set Interaction
The active workout screen MUST prioritize the current set interaction over the full set list, presenting one dominant logging interaction for the active set.

The refactored logger MUST integrate exercise switching into the compact exercise preview rather than dedicating a separate full-width exercise rail in the default layout.

#### Scenario: Advancing through a workout
- **WHEN** the user moves from one set to the next
- **THEN** the screen keeps the current set control as the main interaction focal point and updates surrounding progress context accordingly.

#### Scenario: Finishing a set
- **WHEN** the user activates the set-complete action by tap or accepted upward gesture
- **THEN** local completion state changes immediately
- **AND** visual success feedback runs without delaying or controlling whether the command commits.

#### Scenario: Performing a fast flick
- **WHEN** the user releases the card quickly enough to pass the velocity threshold before reaching the full distance threshold
- **THEN** the intended dominant direction still resolves smoothly
- **AND** no network request is required before the next local state appears.
