## ADDED Requirements

### Requirement: Default Target Population
The system MUST auto-populate input fields for sets and weight with the calculated next state target values from the rule engine.

#### Scenario: Displaying next set
- **WHEN** the user navigates to an upcoming exercise set
- **THEN** the reps and weight fields are pre-filled with the calculated targets based on the plan rules.

### Requirement: Gesture-based Value Adjustments
The app MUST support swipe or press-and-hold gestures to increment or decrement reps and weight inputs without opening the mobile keyboard.

#### Scenario: Dragging to decrease reps
- **WHEN** a user horizontally drags on the reps input box towards the left
- **THEN** the value decrements instantly without prompting the system keyboard.

### Requirement: Underlying Rest Timer
The system MUST provide a background rest timer that automatically starts upon concluding an exercise set.

#### Scenario: Starting a rest period
- **WHEN** the user checks a set as complete
- **THEN** a floating rest timer visually begins counting down or up, persistent across screen navigation.
