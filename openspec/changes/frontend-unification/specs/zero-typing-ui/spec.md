## MODIFIED Requirements

### Requirement: Gesture-based Value Adjustments
The app MUST support swipe or press-and-hold gestures to increment or decrement reps and weight inputs without opening the mobile keyboard, integrated into a visually distinct but minimalist layout where tap targets are seamlessly embedded, and that behavior MUST remain preserved after the active session screen is redesigned to match the dashboard visual style.

#### Scenario: Dragging to decrease reps
- **WHEN** a user horizontally drags on the reps input box towards the left
- **THEN** the value decrements instantly without prompting the system keyboard, maintaining an uncluttered, distraction-free active session UI.

#### Scenario: Workout screen is visually unified
- **WHEN** the active session screen adopts dashboard-style cards and grouping
- **THEN** rep and weight adjustments remain immediate and thumb-friendly instead of becoming secondary or hidden behind denser controls.

### Requirement: Underlying Rest Timer
The system MUST provide a background rest timer that automatically starts upon concluding an exercise set, implemented as an elegantly styled, non-intrusive bottom widget using modern shadow depth techniques, and the rest-timer presentation MUST remain visually integrated with the unified screen language.

#### Scenario: Starting a rest period
- **WHEN** the user checks a set as complete
- **THEN** an elegant floating rest timer visually begins counting down or up, gracefully animating in and persistent across screen navigation, without crowding the primary exercise tracking inputs.
