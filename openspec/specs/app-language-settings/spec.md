## MODIFIED Requirements

### Requirement: Premium Settings Grouping
The profile/settings screen MUST present language settings inside a premium minimal grouped layout rather than a single plain black list block.

The language selector MUST remain immediately understandable in both English and Chinese.

#### Scenario: Opening profile settings
- **WHEN** the user navigates to the profile/settings page
- **THEN** the language preference appears inside a clearly framed premium settings group with strong visual hierarchy.

### Requirement: Premium Selection Tiles
Language options MUST be rendered as premium selection tiles with clear selected/unselected states that feel intentional rather than default radio-list rows.

#### Scenario: Comparing language options
- **WHEN** the user views English and Chinese options
- **THEN** the selected state is communicated through a premium tile treatment, not only by a small radio icon.

### Requirement: Bilingual Clarity In Premium Layout
The premium redesign MUST preserve legibility and tappable area quality for bilingual labels in the settings experience.

#### Scenario: Switching app language
- **WHEN** the user views or changes language options
- **THEN** English and Chinese labels remain readable, unclipped, and easy to distinguish inside the premium visual treatment.

### Requirement: Bilingual Training Reference Access
The profile/settings area MUST expose an entry point to the bundled set-type guide and render that guide in the user's selected app language.

#### Scenario: User opens the guide from profile
- **WHEN** the user enters the profile/settings area and taps the training set guide entry
- **THEN** the app opens the bundled markdown reference in the currently selected language.
