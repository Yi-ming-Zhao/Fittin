## Purpose

Define advanced analytics views that help users interpret consistency, volume distribution, and training load over time.

## ADDED Requirements

### Requirement: Consistency Heatmap
The system MUST provide a 90-day square grid (heatmap) showing the frequency and intensity of training sessions, with an overall consistency score percentage.

#### Scenario: Visualizing 3-month consistency
- **WHEN** the user views the Advanced Analytics screen
- **THEN** they see a grid where each square represents a day
- **AND** squares are colored based on whether a workout was completed, matching the GitHub contribution style but adapted to the app's dark theme.

### Requirement: Muscle Volume Distribution
The system MUST visualize weekly set volume per muscle group using horizontal progress bars.

#### Scenario: Checking training balance
- **WHEN** a user reviews the analytics
- **THEN** they see horizontal bars for categories like "Chest", "Lats", "Quads"
- **AND** each bar shows the number of completed sets relative to a target (e.g., 9/10 sets).

### Requirement: Anatomical Load Visualization
The system SHOULD include an anatomical human body diagram where muscle groups are highlighted based on their relative training load in the current training cycle.

#### Scenario: Quick scan of muscle focus
- **WHEN** the user opens the training load tab
- **THEN** an anatomical diagram displays variations in highlight intensity on specific muscle groups reflecting the volume distribution.
