## Purpose

Define the Profile hub and stable second-level settings destinations.

## Requirements

### Requirement: Profile category navigation
The profile root SHALL show the user identity and a short list of coherent second-level destinations for account, appearance, training preferences, data and privacy, Agent, and app information instead of mixing their controls inline.

#### Scenario: User opens My
- **WHEN** the profile root appears on a narrow phone
- **THEN** each category is represented once with a title, concise status, icon, disclosure affordance, and at least a 44 px touch target.

### Requirement: Stable second-level settings
Each second-level page MUST own one related group of settings, provide platform-correct back navigation, and preserve its state when returning to the profile root.

#### Scenario: User changes appearance then returns
- **WHEN** the user changes a palette in Appearance and navigates back
- **THEN** the profile root reflects the selected palette without resetting another settings category.
