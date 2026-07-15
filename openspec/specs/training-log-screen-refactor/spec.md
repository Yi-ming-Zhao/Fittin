## Purpose

Define the compact single-screen workout logger layout, controls, and interaction model for mobile-first set logging.

## Requirements

### Requirement: Single-Screen Mobile Workout Logger
The training log screen MUST present its core recording workflow within a single mobile viewport for common phone sizes, without requiring vertical scrolling during normal set logging.

The visible primary layout MUST include:
- workout context header
- compact exercise preview
- current-set controls
- set progress
- conclude workout action

#### Scenario: Recording a normal working set on mobile
- **WHEN** the user opens an active workout on a typical phone-sized viewport
- **THEN** they can see and use the current exercise preview, current-set controls, progress indicator, and conclude action without scrolling the page vertically.

### Requirement: Compact Exercise Preview
The top exercise preview MUST be reduced in height and only show information needed for the current recording decision.

The preview MUST include:
- current exercise name
- current set index and total set count
- tier
- target weight and reps or AMRAP marker
- target RPE when present
- the active display unit for the exercise

The preview MUST NOT show:
- scheme / stage identifier as a visible field
- completed set count summary text
- previous set weight x reps summary text
- extra explanatory subtitle text

#### Scenario: Viewing the active exercise
- **WHEN** the user opens the workout logger
- **THEN** the top preview is visually compact and does not include scheme, previous-set summary, or redundant helper copy.

#### Scenario: Switching exercise unit display
- **WHEN** the user changes the active exercise between kg and lb
- **THEN** the preview and current-set controls update the displayed target and actual weight values to the selected unit
- **AND** the choice applies only to that exercise inside the current workout session.

### Requirement: Exercise Switching Inside Preview
Exercise switching MUST be integrated into the exercise preview via a compact icon action that opens a premium dropdown or anchored menu.

The menu MUST:
- list all exercises in the current workout
- highlight the active exercise
- allow switching with one tap
- animate with restrained premium motion

#### Scenario: Switching exercises from the preview
- **WHEN** the user taps the exercise switch icon in the preview card
- **THEN** the app opens a compact animated menu from that control and lets the user switch to another exercise without using a separate full-width rail.

### Requirement: Workout Context Title Format
The workout header MUST combine week/day context and workout name into a single compact title string.

The preferred format MUST be `WnDn-Workout Name`.

#### Scenario: Opening the first workout of week one
- **WHEN** the user opens the first workout in week one
- **THEN** the header title is shown in a compact combined form such as `W1D1-Squat & Pull`.

### Requirement: Correct Set Recording Controls
The current-set control area MUST expose valid and useful actions for set recording while supporting faster direct editing.

The screen MUST include:
- increment reps
- decrement reps
- adjust current recorded weight
- direct numeric weight entry from the current weight display
- edit recorded RPE
- complete/log current set
- skip current set

The screen MUST NOT include a reset-reps action.

#### Scenario: Adjusting reps during a set
- **WHEN** the user taps the decrement control
- **THEN** completed reps decrease by one but never below zero.

#### Scenario: Logging the current set
- **WHEN** the user taps the centered set completion action or performs an accepted upward completion gesture
- **THEN** the current set is marked complete immediately in local session state
- **AND** the session advances to the next logical unresolved set or exercise state.

#### Scenario: Entering weight directly
- **WHEN** the user taps the current weight display
- **THEN** the logger opens a direct numeric entry path for the current set's weight
- **AND** saving the value updates the same set without requiring repeated plus/minus taps.

#### Scenario: Recording actual RPE
- **WHEN** the current set includes a target RPE or the user wants to record exertion
- **THEN** the logger shows an editable actual RPE control for that set
- **AND** the user can save the set with reps, weight, and RPE together.

#### Scenario: Skipping the current set
- **WHEN** the user taps the centered skip action or performs an accepted downward skip gesture
- **THEN** the set is marked skipped rather than completed
- **AND** the session advances without counting the skipped set as progression success.

### Requirement: Selectable Card And Traditional Recording Modes
The active workout screen MUST support a card recording mode and a traditional recording mode while using the same underlying workout draft and actions.

#### Scenario: Opening the selected logger
- **WHEN** the user starts or resumes a workout
- **THEN** the current-set controls render in the recording mode saved in settings
- **AND** switching modes does not discard reps, weight, RPE, completion, skip, or exercise selection state.

### Requirement: Live Current-Set Card Stack
Card recording mode MUST present the current set as the dominant foreground card and show upcoming unresolved sets as a compact layered stack that reacts continuously to the foreground drag.

#### Scenario: Dragging the active card
- **WHEN** the user drags the current card in any supported direction without releasing it
- **THEN** the foreground card translates with the pointer and exposes direction-specific feedback
- **AND** the next cards expand toward the foreground position in real time.

#### Scenario: Gesture does not meet a threshold
- **WHEN** the user releases the current card before either its distance or velocity threshold
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

### Requirement: Velocity-Aware Four-Way Card Gestures
Card recording mode MUST recognize the dominant supported direction when either drag distance or release velocity passes its configured threshold. Left and right MUST navigate to the next and previous set, while up and down MUST complete and skip the displayed set.

#### Scenario: User performs a short fast vertical flick
- **WHEN** the card has little sampled displacement but is released with dominant upward or downward velocity above the fling threshold
- **THEN** the logger resolves the gesture as complete or skip according to its direction
- **AND** it does not misclassify the gesture as horizontal.

#### Scenario: User performs a short fast horizontal flick
- **WHEN** the card is released with dominant leftward or rightward velocity above the fling threshold
- **THEN** the logger navigates to the next or previous set according to its direction without mutating completion state.

#### Scenario: Gesture is below both thresholds
- **WHEN** neither displacement nor release velocity passes its threshold
- **THEN** the card returns to rest and session data remains unchanged.

### Requirement: Immediate Exactly-Once Gesture Resolution
An accepted card gesture MUST apply its local session command exactly once before decorative completion or fly-out animation can finish, fail, or be cancelled.

#### Scenario: Completion animation is restarted
- **WHEN** a later interaction restarts or cancels a decorative ticker animation
- **THEN** every previously accepted completion or skip command remains committed exactly once.

#### Scenario: User flicks quickly during slow persistence
- **WHEN** local persistence has not completed for the prior card command
- **THEN** the accepted command is already visible in local session state
- **AND** persistence latency does not change gesture recognition.

### Requirement: Lightweight Progress Indicator
The logger MUST represent set progress in a compact visual indicator rather than relying on an expanded scrolling set list.

#### Scenario: Seeing current progress
- **WHEN** the user is on set 3 of 6
- **THEN** the progress strip clearly shows completed sets, the active set, and remaining sets in a compressed layout.

#### Scenario: Jumping to a set from the progress strip
- **WHEN** the user taps a set marker in the progress strip
- **THEN** the logger focuses that set for editing
- **AND** the current-set controls update to the tapped set instead of remaining locked to the previous position.
