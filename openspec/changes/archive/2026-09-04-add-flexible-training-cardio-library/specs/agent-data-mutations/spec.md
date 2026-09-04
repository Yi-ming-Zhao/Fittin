## ADDED Requirements

### Requirement: Exercise and palette library tools
The Agent SHALL receive bounded, owner-scoped tools to list and inspect exercise and palette entries and proposal-only tools to create, revise, or delete custom entries.

#### Scenario: Agent finds a substitute movement
- **WHEN** the user asks for a knee-friendly leg exercise
- **THEN** the Agent can query catalog tags and return matching definitions without receiving unrelated private data

#### Scenario: Agent changes a custom exercise
- **WHEN** the Agent proposes a tag or name change
- **THEN** the system shows every changed field and writes only after user confirmation

### Requirement: Built-in catalog protection
The Agent MUST NOT modify or delete bundled exercise or palette entries; a requested revision MUST be represented as creation of a custom copy.

#### Scenario: Agent targets a built-in palette
- **WHEN** the model calls a revision tool for a built-in palette ID
- **THEN** the tool returns a validation error or proposes a new custom-copy ID without modifying the built-in
