## MODIFIED Requirements

### Requirement: Correct Set Recording Controls
The current-set control area MUST expose valid and useful actions for set recording while supporting fast direct editing.

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

## ADDED Requirements

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
