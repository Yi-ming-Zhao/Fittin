## ADDED Requirements

### Requirement: Language Settings Entry
The system MUST provide a settings entry under the personal/profile tab where the user can manage app language.

#### Scenario: User opens personal tab
- **WHEN** the user selects the bottom-navigation personal/profile destination
- **THEN** the app shows a settings-oriented surface
- **AND** that surface includes an entry for language preferences.

### Requirement: Persistent App Language Selection
The system MUST let the user choose between English and Chinese and MUST persist that choice locally.

#### Scenario: User switches app language
- **WHEN** the user selects Chinese or English in language settings
- **THEN** the app saves that preference locally
- **AND** applies the selected language immediately across the app shell without requiring a restart.

#### Scenario: App restarts after language was changed
- **WHEN** the app is launched after the user previously selected Chinese or English
- **THEN** the app restores the saved language preference
- **AND** renders the UI using that language from startup.

### Requirement: Localized App Chrome
The system MUST localize app-owned interface text for English and Chinese.

#### Scenario: User is in Chinese mode
- **WHEN** the selected app language is Chinese
- **THEN** navigation labels, settings labels, dashboard text, plan library actions, active session labels, and share-related app chrome MUST render in Chinese.

#### Scenario: User is in English mode
- **WHEN** the selected app language is English
- **THEN** those same app-owned interface texts MUST render in English.
