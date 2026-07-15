## Purpose

Define the no-keyboard, gesture-first interaction rules that keep workout logging focused on quick touch-driven set entry.

## Requirements

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

### Requirement: Four-Way Card Resolution Gestures
In card recording mode, the logger MUST recognize the dominant supported direction when either drag distance or release velocity passes its configured threshold. Left and right MUST navigate to the next and previous set, while up and down MUST complete and skip the displayed set.

#### Scenario: Completing by swiping up
- **WHEN** the user releases the current card upward beyond the distance threshold or with dominant upward velocity above the fling threshold
- **THEN** the set is recorded as complete and the next unresolved card becomes current.

#### Scenario: Skipping by swiping down
- **WHEN** the user releases the current card downward beyond the distance threshold or with dominant downward velocity above the fling threshold
- **THEN** the set is marked skipped rather than completed
- **AND** the skipped set cannot satisfy progression success criteria.

#### Scenario: Navigating horizontally
- **WHEN** the user performs an accepted left or right gesture
- **THEN** the logger moves to the next or previous set without changing completion state.

#### Scenario: Gesture stays below both thresholds
- **WHEN** neither displacement nor release velocity reaches its configured threshold
- **THEN** the card returns to rest and the workout draft remains unchanged.

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

### Requirement: No Rest Timer Dependency in Primary Layout
The redesigned workout logger MUST NOT require a visible rest timer module as part of its primary layout composition.

The refactored logger MUST also NOT expose a visible reset-reps action in the primary layout.

#### Scenario: Using the redesigned logger
- **WHEN** the user logs reps and completes sets
- **THEN** the main screen remains focused on set interaction and set progression without a rest timer surface or reset-reps control occupying prime space.
