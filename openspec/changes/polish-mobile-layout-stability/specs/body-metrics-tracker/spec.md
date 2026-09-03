## MODIFIED Requirements

### Requirement: Metric Grid Comparison
The system MUST support body fat, waist circumference, and check-in count in a responsive metric composition. On narrow phones, body fat and waist MUST use two readable columns and Check-ins MUST use a full-width row; at widths of at least 520 px, all three MAY share a row. Each metric summary MUST resolve its current and previous values from the most recent records where that specific field is present, and MUST only use records owned by the active user.

#### Scenario: Reviewing body summaries on a narrow phone
- **WHEN** the user views Body Metrics below 520 px wide
- **THEN** body fat and waist values, units, and comparison captions remain readable side by side
- **AND** the Check-ins summary occupies a full-width card below them.

#### Scenario: Reviewing fat loss progress
- **WHEN** current and previous body fat and waist measurements are available
- **THEN** body fat and waist cards show the latest value and change from the previous comparable measurement
- **AND** the responsive layout preserves their supporting visual priority.

#### Scenario: Reviewing a metric without comparison data
- **WHEN** the user has a current waist or body fat value but no prior comparable measurement
- **THEN** the relevant card shows the latest value
- **AND** the card explains that trend comparison is not available yet
- **AND** the page avoids displaying a misleading zero-change or blank delta treatment.

#### Scenario: User switches accounts on the same device
- **WHEN** authentication changes from one user to another while the Body tab remains mounted
- **THEN** the provider reloads only the new owner's measurements
- **AND** edit or delete operations cannot address rows owned by the previous account.
