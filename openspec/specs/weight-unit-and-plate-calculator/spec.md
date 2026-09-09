## Purpose

Define the reusable weight-conversion, bar-weight preference, and plate-loading guidance behaviors shared by settings and the active workout logger.

## Requirements

### Requirement: Reusable Weight Conversion Tool
The system MUST provide a reusable weight conversion tool that can be opened from the profile/settings experience and from the active workout logger.

#### Scenario: User opens the converter from settings
- **WHEN** the user opens the profile/settings area and selects the weight tools entry
- **THEN** the app opens a bilingual conversion surface that can translate between kilograms and pounds
- **AND** the user can use the tool without leaving the settings flow.

#### Scenario: User opens the converter during a workout
- **WHEN** the user opens the weight tools surface from the active workout logger
- **THEN** the conversion view initializes from the current set's weight and unit context
- **AND** the user can close it without losing their current workout progress.

### Requirement: Default Bar Weight Preferences
The system MUST let the user configure separate default bar weights for kilogram and pound plate calculations.

#### Scenario: User updates kilogram bar weight
- **WHEN** the user changes the default kilogram bar weight in settings
- **THEN** later kilogram plate calculations use the updated bar weight
- **AND** the preference persists across app restarts and browser refreshes.

### Requirement: Barbell Plate Breakdown Guidance
The system MUST show plate-loading guidance for supported barbell exercises when the current display unit is kilograms or pounds.

#### Scenario: User views kilogram plate guidance
- **WHEN** a barbell exercise is being logged in kilograms
- **THEN** the logger or weight tools surface shows a per-side breakdown using the supported kg plate denominations
- **AND** the guidance reflects the configured kilogram bar weight.

#### Scenario: User views pound plate guidance
- **WHEN** a barbell exercise is being logged in pounds
- **THEN** the logger or weight tools surface shows a per-side breakdown using the supported lb plate denominations
- **AND** the guidance reflects the configured pound bar weight.

### Requirement: Equipment specific dumbbell weight
Dumbbell exercises SHALL display a dumbbell weight illustration instead of a barbell plate stack and SHALL explicitly label per-hand versus combined load according to exercise semantics.

#### Scenario: Record a dumbbell press
- **WHEN** a user changes the current dumbbell weight
- **THEN** the illustration updates immediately in the selected unit and no barbell plate guidance is shown.
