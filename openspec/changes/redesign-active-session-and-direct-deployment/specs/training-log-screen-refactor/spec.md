## MODIFIED Requirements

### Requirement: Correct Set Recording Controls
The current-set control area MUST expose valid and useful actions for set recording while supporting faster direct editing.

The screen MUST include:
- increment reps
- decrement reps
- adjust current recorded weight
- direct numeric weight entry from the current weight display
- edit recorded RPE
- complete/log current set

The screen MUST NOT include a reset-reps action.

#### Scenario: Adjusting reps during a set
- **WHEN** the user taps the decrement control
- **THEN** completed reps decrease by one but never below zero.

#### Scenario: Logging the current set
- **WHEN** the user taps the centered set completion action or uses the selected mode's completion gesture
- **THEN** the current set is marked complete and the session advances to the next logical set or exercise state.

#### Scenario: Entering weight directly
- **WHEN** the user taps the current weight display
- **THEN** the logger opens a direct numeric entry path for the current set's weight
- **AND** saving the value updates the same set without requiring repeated plus/minus taps.

#### Scenario: Recording actual RPE
- **WHEN** the current set includes a target RPE or the user wants to record exertion
- **THEN** the logger shows an editable actual RPE control for that set
- **AND** the user can save the set with reps, weight, and RPE together.

## ADDED Requirements

### Requirement: Selectable Card And Traditional Recording Modes
The active workout screen MUST support a card recording mode and a traditional recording mode while using the same underlying workout draft and actions.

#### Scenario: Opening the selected logger
- **WHEN** the user starts or resumes a workout
- **THEN** the current-set controls render in the recording mode saved in settings
- **AND** switching modes does not discard reps, weight, RPE, completion, cancellation, or exercise selection state.

### Requirement: Live Current-Set Card Stack
Card recording mode MUST present the current set as the dominant foreground card and show upcoming unresolved sets as a compact layered stack that reacts continuously to the foreground drag.

#### Scenario: Dragging the active card
- **WHEN** the user drags the current card left or down without releasing it
- **THEN** the foreground card translates with the pointer and exposes direction-specific feedback
- **AND** the next cards expand toward the foreground position in real time.

#### Scenario: Gesture does not meet a threshold
- **WHEN** the user releases the current card before a completion or cancellation threshold
- **THEN** the card returns to its resting position without changing session data.

### Requirement: Graphical Barbell Plate Breakdown
When plate breakdown is available, the logger MUST show an abstract mirrored barbell with visually distinct plates in addition to the numeric loading summary.

#### Scenario: Viewing a loadable barbell weight
- **WHEN** the current set weight produces a valid plate breakdown
- **THEN** the plate module renders a bar, collars, and matching plates on both sides
- **AND** the equivalent per-side plate values remain available as text for precision and accessibility.

### Requirement: Centered Primary Confirmation
The visible set completion action MUST be horizontally centered within the current-set interaction area in both recording modes.

#### Scenario: Completing without a swipe
- **WHEN** the user prefers tapping or assistive navigation over gestures
- **THEN** they can activate the centered completion action to record the current set.
