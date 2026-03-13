## 1. Analytics Domain and Data Access

- [x] 1.1 Add an analytics service/provider that reads workout logs and builds per-exercise progress histories.
- [x] 1.2 Implement estimated-1RM formula utilities for Brzycki, Epley, Landers, Lombardi, Mayhew, O'Conner, and Wathan.
- [x] 1.3 Add eligibility rules for e1RM candidate sets and separate actual 1RM detection from estimated 1RM calculation.
- [x] 1.4 Add derived analytics helpers for PR detection, recent change windows, frequency, tonnage, and stagnation flags.

## 2. Analytics State and Preferences

- [x] 2.1 Add persisted analytics preferences for the selected estimated-1RM formula.
- [x] 2.2 Expose view models for summary cards, exercise ranking/list rows, and exercise detail trend data.
- [x] 2.3 Ensure analytics state reacts to new workout logs and app-language changes without requiring app restart.

## 3. Progress Analytics UI

- [x] 3.1 Replace the third bottom-navigation page content with a dedicated progress analytics screen.
- [x] 3.2 Build the analytics summary section for recent frequency, tonnage, and notable progress highlights.
- [x] 3.3 Build the all-exercise progress list with current estimated 1RM, actual 1RM status, recent changes, and drill-down entry.
- [x] 3.4 Build the exercise detail presentation for e1RM trend, actual 1RM history, best set details, PR events, and stagnation messaging.
- [x] 3.5 Add formula selection controls and bilingual analytics labels and empty states.

## 4. Verification

- [x] 4.1 Add unit tests for 1RM formulas, actual-vs-estimated classification, and analytics aggregation.
- [x] 4.2 Add widget tests for the third-tab analytics screen, formula switching, and localized labels.
- [x] 4.3 Run the relevant automated tests and verify analytics rendering works with existing workout-log data.
