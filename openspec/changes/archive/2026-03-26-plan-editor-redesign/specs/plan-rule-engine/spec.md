## ADDED Requirements

### Requirement: Engine-Aware Editor Rule Surface
The system MUST expose rule-editing controls according to the selected template's engine family and scheduling mode instead of showing one universal rule form.

#### Scenario: User edits a linear template
- **WHEN** a user opens the editor for a `linear_tm` template
- **THEN** the available rule fields include linear progression concepts such as success behavior, failure behavior, and reset-oriented actions.

#### Scenario: User edits a periodized template
- **WHEN** a user opens the editor for a `periodized_tm` template
- **THEN** the available rule fields exclude linear-only controls such as `on_success` and `on_failure`
- **AND** the editor only exposes rule inputs that make sense for fixed-slot periodized prescriptions.

### Requirement: Set Type Compatibility Enforcement
The system MUST reject or normalize unsupported combinations of set type, engine family, and load-expression metadata before a template can be saved.

#### Scenario: Unsupported set behavior is chosen
- **WHEN** a user selects a set type or rule combination that the target engine family cannot execute
- **THEN** the editor prevents save and surfaces a validation message describing the incompatible combination.
