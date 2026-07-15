## ADDED Requirements

### Requirement: Navigable Historical Calendar
The consistency experience MUST provide a real calendar with localized month/year heading, weekday labels, complete calendar-week rows, previous/next month navigation, a return-to-current-month action, and recorded-day selection across all available history.

#### Scenario: User navigates beyond the recent month
- **WHEN** the user moves to an earlier month containing completed workouts
- **THEN** the calendar renders that calendar month, marks its actual recorded dates, and allows the user to open a marked day's records.

#### Scenario: Month has leading or trailing days
- **WHEN** a calendar month does not begin on the locale's first weekday or end on its last weekday
- **THEN** the view renders aligned complete week rows with out-of-month dates visually distinguished rather than truncating the grid.

## MODIFIED Requirements

### Requirement: Anatomical Load Visualization
The system MUST include front and back anatomical human diagrams with individually addressable muscle regions highlighted from real completed-set volume in the selected period.

The visualization MUST provide a localized legend, a no-data state, intensity normalization, and tap details naming the selected muscle and its completed-set count. It MUST distinguish at least chest, shoulders, biceps, triceps, upper back/lats, core, glutes, quadriceps, hamstrings, and calves without presenting a placeholder silhouette as completed data.

#### Scenario: Quick scan of muscle focus
- **WHEN** the user opens the training-load tab with completed workout data
- **THEN** front and back diagrams highlight the exercised muscle regions at relative intensities calculated from actual volume
- **AND** tapping a highlighted region identifies the muscle and the contributing completed-set count.

#### Scenario: No categorized volume exists
- **WHEN** the selected period has no completed sets mapped to canonical muscle groups
- **THEN** the diagram remains anatomically visible but unhighlighted and presents a localized no-data explanation.
