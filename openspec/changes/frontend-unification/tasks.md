## 1. Shared Presentation Primitives

- [ ] 1.1 Audit the home dashboard’s spacing, card, border, and typography patterns and extract reusable presentation helpers for section labels, grouped surfaces, and compact stat/action cards.
- [ ] 1.2 Add shared styling wrappers or widgets so non-home screens can adopt the same layout rhythm without duplicating container code.

## 2. Active Workout Redesign

- [ ] 2.1 Refactor the active session screen header, exercise rail, and set list into the unified dashboard-style layout.
- [ ] 2.2 Update the conclude action area and rest-timer integration so the page feels visually consistent while preserving zero-typing speed and large tap targets.
- [ ] 2.3 Apply the same surface treatment and motion feedback to set rows, chips, and interactive workout controls.

## 3. Analytics and Profile Redesign

- [ ] 3.1 Restage the progress analytics screen into the same visual language as the home dashboard, including section grouping and softer card hierarchy.
- [ ] 3.2 Redesign the profile/settings screen with dashboard-style grouped sections and a clearer premium settings layout.
- [ ] 3.3 Ensure bilingual labels and existing controls still fit the unified layout without clipping or density regressions.

## 4. Verification

- [ ] 4.1 Add or update widget tests covering the redesigned workout, analytics, and profile screens.
- [ ] 4.2 Run the relevant automated tests and verify navigation, localization, and core interactions still behave correctly after the visual refactor.
