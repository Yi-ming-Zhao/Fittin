# zero-typing-ui Specification

## Purpose
Define a mobile workout logging experience that avoids keyboard entry by relying on prefilled targets, direct manipulation, and low-friction set interactions.

## Requirements
### Requirement: Default Target Population
The system MUST auto-populate input fields for sets and weight with the calculated next state target values from the rule engine.

#### Scenario: Displaying next set
- **WHEN** the user navigates to an upcoming exercise set
- **THEN** the reps and weight fields are pre-filled with the calculated targets based on the plan rules.

### Requirement: Gesture-based Value Adjustments
The app MUST support swipe or press-and-hold gestures to increment or decrement reps and weight inputs without opening the mobile keyboard, integrated into a visually distinct but minimalist layout where tap targets are seamlessly embedded.

#### Scenario: Dragging to decrease reps
- **WHEN** a user horizontally drags on the reps input box towards the left
- **THEN** the value decrements instantly without prompting the system keyboard, maintaining an uncluttered, distraction-free active session UI.

### Requirement: Underlying Rest Timer
The system MUST provide a background rest timer that automatically starts upon concluding an exercise set, implemented as an elegantly styled, non-intrusive bottom widget using modern shadow depth techniques.

#### Scenario: Starting a rest period
- **WHEN** the user checks a set as complete
- **THEN** an elegant floating rest timer visually begins counting down or up, gracefully animating in and persistent across screen navigation, without crowding the primary exercise tracking inputs.
