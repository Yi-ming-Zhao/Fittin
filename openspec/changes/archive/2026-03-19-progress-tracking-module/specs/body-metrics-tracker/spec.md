## ADDED Requirements
 
### Requirement: Visual Consistency with Home Dashboard
The Body Metrics module MUST follow the Premium Glassmorphism style: using `onSurface.withValues(alpha: 0.03)` base layers, thin borders, and vibrant primary-color highlights for primary call-to-actions.
 

### Requirement: Historical Body Metric Charting
The system MUST provide line charts for tracking changes in body weight over time, appearing prominently in the Body Metrics module.

#### Scenario: User records weight
- **WHEN** the user adds a new weight entry of 78.5 kg
- **THEN** the historical line graph updates immediately to include the new data point
- **AND** the primary display updates to the latest value.

### Requirement: Metric Grid Comparison
The system MUST support tracking of secondary body metrics (Body Fat %, Waist Circumference) in a tiled grid layout that emphasizes the delta from the previous measurement.

#### Scenario: Reviewing fat loss progress
- **WHEN** the user views the Body Metrics screen
- **THEN** cards for "Body Fat" and "Waistline" show the current percentage/measurement alongside a color-coded percentage change (e.g., -1.2%).

### Requirement: Progress Photo Vault
The system MUST support storing and viewing progress photos, specifically enabling a side-by-side comparison mode between two selected dates.

#### Scenario: Comparing photos
- **WHEN** the user enters the photo comparison mode
- **THEN** the system displays two selected photos labeled "Today" and "[Date]" for visual side-by-side review.
