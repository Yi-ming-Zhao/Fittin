## Purpose

Define the exercise-level analytics and history experience for inspecting performance trends for a single movement.

## ADDED Requirements

### Requirement: Exercise-Specific Strength Trend Overlay
The Exercise Deep Dive screen MUST present an overlay chart showing 1RM, 3RM, and 5RM trends simultaneously for the selected exercise.

#### Scenario: Analyzing strength trends
- **WHEN** a user opens the "Deep Dive" for Barbell Back Squat
- **THEN** the system renders a chart where three distinct line paths represent the progression of different top-set rep ranges over time.

### Requirement: Exercise Hero Presentation
The deep dive MUST feature high-contrast, black-and-white imagery representing the exercise at the top of the screen to maintain the premium dark-mode aesthetic.

#### Scenario: Loading exercise details
- **WHEN** the user navigates to any exercise detail view
- **THEN** the screen displays a monochromatic hero image corresponding to the exercise identity.

### Requirement: Filtered Session History
The system MUST provide a reverse-chronological list of all training sessions that included the active exercise, showing weight, reps, and RPE for each set.

#### Scenario: Checking past performance
- **WHEN** the user scrolls down on the deep dive page
- **THEN** they see an "Activity History" section filtered specifically to this exercise's performance history.
