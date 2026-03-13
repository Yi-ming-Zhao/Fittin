## 1. Jacked & Tan Built-in Plan

- [x] 1.1 Read `jacked_and_tan.xlsx` and emit a normalized Jacked & Tan JSON asset that preserves the workbook T1 structure while applying the reduced T2/T3 exercise selection from the design.
- [x] 1.2 Add seed/bootstrap support so the app stores both built-in templates idempotently instead of only GZCLP.
- [x] 1.3 Add plan-asset validation tests that verify the Jacked & Tan weekly muscle-group direct-set budget stays within 12 to 20 sets and that the selected movements match the approved lineup.

## 2. Active Plan Persistence

- [x] 2.1 Extend local storage with a durable active-instance selection record that can survive app restarts independently of templates and workout logs.
- [x] 2.2 Add repository and service APIs for listing switchable plans, resolving or creating an instance for a selected template, and updating the active instance atomically.
- [x] 2.3 Update today-workout/session loading to read from the active instance pointer instead of assuming the seeded GZCLP instance is always current.

## 3. Navigation and Plan Switching UI

- [x] 3.1 Refactor the app shell so the floating bottom navigation controls real tab destinations, with the second tab opening the plan library.
- [x] 3.2 Update the plan library to act as a preview-and-switch screen that shows built-in/custom badges, active-plan state, workout summaries, and a switch action.
- [x] 3.3 Ensure switching plans refreshes the dashboard hero card and session launch path immediately without losing the saved instance for the previously active plan.

## 4. Verification

- [x] 4.1 Add unit tests for active-instance persistence, plan switching, and repository behavior when a template already has an instance versus when it needs a new one.
- [x] 4.2 Add widget tests for bottom-nav tab routing, plan-library preview rendering, active-plan indicators, and dashboard updates after a plan switch.
- [x] 4.3 Run the relevant automated tests and verify that both built-in plans still serialize/export through the existing JSON/QR sharing flow.
