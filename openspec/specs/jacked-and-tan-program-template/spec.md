## ADDED Requirements

### Requirement: Training-Max-Driven Jacked & Tan Activation
The built-in Jacked & Tan template MUST derive weekly prescribed loads from user-entered training max values and workbook-defined percentage tables.

#### Scenario: User starts Jacked & Tan from scratch
- **WHEN** the user creates the first Jacked & Tan instance after entering the required training max values
- **THEN** the app calculates the current week's prescribed set weights from those training max values, the exercise lift mappings, the workbook-derived weekly percentages, and the configured rounding rules.

### Requirement: Fixed Weekly Periodization
The built-in Jacked & Tan template MUST preserve fixed week-by-week prescriptions and MUST NOT reuse the linear progression logic used by GZCLP.

#### Scenario: User completes a hard week
- **WHEN** the user logs a Jacked & Tan workout that was difficult or unusually easy
- **THEN** the next scheduled Jacked & Tan workout still resolves its weights from the predefined next week/block prescription rather than from linear load carry-forward.

## MODIFIED Requirements

### Requirement: Built-in Jacked & Tan 2.0 Template
The system MUST ship with a built-in Jacked & Tan 2.0 template derived from the checked-in workbook `/Users/yzxbb/Desktop/Fittin_v2/jacked_and_tan.xlsx`, seeded alongside the existing GZCLP template as app-owned JSON data, and it MUST model Jacked & Tan as a periodized training-max-driven program rather than a linear progression template.

#### Scenario: Empty database is initialized
- **WHEN** the app boots with no stored templates or with only one built-in template present
- **THEN** it seeds the normalized Jacked & Tan 2.0 template in addition to GZCLP without deleting user-authored templates
- **AND** the seeded template includes the engine metadata needed to resolve fixed weekly prescriptions from training max values.
