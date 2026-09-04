## ADDED Requirements

### Requirement: User-defined semantic palettes
The system SHALL let users preview, create, rename, revise, duplicate, and delete custom semantic palettes while keeping built-in palettes immutable.

#### Scenario: User edits a built-in palette
- **WHEN** the user starts editing a built-in palette
- **THEN** the system creates a custom copy and leaves the built-in definition unchanged

#### Scenario: Active custom palette is deleted
- **WHEN** the user deletes the currently selected custom palette
- **THEN** the system switches to the default built-in palette before deleting it

### Requirement: Palette safety validation
The system MUST reject malformed color values, cyan or teal hues, insufficient foreground/background contrast, indistinguishable strength/cardio series, and invisible status roles before saving a palette.

#### Scenario: Agent proposes low-contrast text
- **WHEN** a custom palette would fail the required text contrast threshold
- **THEN** the preview identifies the failing role and confirmation remains disabled

### Requirement: Confirmed Agent palette mutations
Agent palette additions, revisions, and deletions MUST use a complete semantic diff, version precondition, explicit confirmation, local audit record, and conflict-safe undo.

#### Scenario: Agent creates a palette
- **WHEN** the Agent proposes a valid restrained palette and the user confirms it
- **THEN** the palette is added to the library but is not activated unless the user explicitly selects it
