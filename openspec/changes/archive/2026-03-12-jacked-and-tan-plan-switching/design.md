## Context

The app now has a JSON-first template system, template editing, and one real built-in GZCLP program, but it still behaves like a single-program product in two important ways: bootstrap only seeds one default training instance, and the bottom navigation does not actually route users into a plan browsing or switching flow. The requested Jacked & Tan addition is not just another asset file; it requires a second built-in program, a durable active-plan selection model, and a shell-level navigation change so plan choice affects the dashboard and session entry path.

The source workbook [jacked_and_tan.xlsx](/Users/yzxbb/Desktop/Fittin_v2/jacked_and_tan.xlsx) contains a 12-week Jacked & Tan 2.0 schedule with T1/T2/T3 structure, but its default accessory volume is too high for the requested use case. The user also wants continuity with the movements already used in the existing GZCLP plan and a program that supports both strength and physique work instead of a pure accessory-sprawl interpretation of the sheet.

## Goals / Non-Goals

**Goals:**
- Ship a built-in Jacked & Tan 2.0 template encoded as JSON and seeded alongside GZCLP.
- Preserve all workbook T1 movements exactly as written while reducing every workout to exactly 2 T2 movements and 2 T3 movements.
- Rebalance the chosen T2/T3 exercises so the resulting weekly direct-set budget lands between 12 and 20 sets for each major target area: chest, back, quads, posterior chain, and shoulders.
- Reuse movements the user has already seen in GZCLP where that improves continuity and adherence.
- Move plan browsing and switching into the second bottom-nav destination so the active plan is visible and switchable from the app shell.
- Persist active plan selection so the dashboard, today-workout card, and session launch all reflect the currently selected plan instance.

**Non-Goals:**
- Rebuild the full workbook authoring surface for Jacked & Tan inside the app.
- Add cloud sync, multi-device active-plan reconciliation, or online program downloads.
- Support arbitrary simultaneous active plans in the dashboard; exactly one plan instance is active at a time.
- Replace the existing QR/JSON share format.

## Decisions

### 1. Add Jacked & Tan as a second built-in JSON asset, not a runtime Excel dependency
The workbook will be translated into a checked-in JSON asset, mirroring the existing GZCLP approach. This keeps startup deterministic, avoids bundling spreadsheet parsing in production, and ensures the new plan remains exportable through the current JSON/QR path.

Alternative considered:
- Parse `.xlsx` at runtime. Rejected because it adds runtime complexity, platform risk, and no product value once the workbook has been normalized.

### 2. Keep T1 unchanged and hard-select a reduced T2/T3 layout tuned for strength plus physique
The seeded Jacked & Tan program will preserve the workbook T1 lineup:
- Day 1: Competition Squat
- Day 2: Bench Press
- Day 3: Auxiliary Squat
- Day 4: Standing Barbell Press, Slingshot Bench

The rebalanced T2/T3 layout will be:

| Day | T2 | T3 |
| --- | --- | --- |
| Day 1 | Block Pull, Leg Press | Barbell Row, Leg Curl |
| Day 2 | Close-Grip Bench Press, Incline DB Bench | DB Seated Press, Lateral Raises |
| Day 3 | Romanian Deadlift, Close-Grip Lat Pulldown | Chest-Supported Row, Walking Lunge |
| Day 4 | Legless Bench Press, Push Press | Wide-Grip Lat Pulldown, Face Pull |

These choices deliberately reuse movements already familiar from GZCLP where possible: Barbell Row, Incline DB Bench, DB Seated Press, Lateral Raises, Chest-Supported Row, and pulldown variants. The goal is to keep movement continuity high while still respecting Jacked & Tan’s upper/lower emphasis.

Using the workbook’s default direct-set structure for the selected movements (`T1 ~= 3 work sets`, `Slingshot Bench = 4 work sets`, `T2 = 4 sets`, `T3 = 3 sets`), the weekly budget lands at:
- Chest: 19 direct sets
- Back: 13 direct sets
- Quads: 13 direct sets
- Posterior chain: 14 direct sets
- Shoulders: 16 direct sets

Walking lunges are treated as mixed quad/glute work in this accounting, which is consistent with the user’s “big muscle group” framing and avoids over-correcting with additional posterior-chain accessories.

Alternative considered:
- Keep the workbook accessory list and simply hide extra rows. Rejected because the remaining weekly volume would still be too high or too redundant for the requested target.
- Preserve the original Day 3 T2 Competition Squat. Rejected because replacing that slot with Romanian Deadlift gives the 4-day template a more balanced posterior-chain distribution without altering T1.

### 3. Seed multiple built-in templates and persist a single active instance pointer
The repository will seed both built-in templates on empty or partial databases. In addition to templates and instances, storage will keep a small app-state record that points to the currently active training instance. Plan switching will:
- reuse an existing instance if the selected template already has one,
- otherwise create a new instance from the selected template,
- update the active instance pointer atomically.

This is cleaner than overloading template metadata with an “active” flag and avoids mutating templates to represent user progress.

Alternative considered:
- Mark one template as active. Rejected because dashboard and workout launch need instance state, not just a template definition.
- Hardcode a second built-in instance ID. Rejected because it does not scale beyond two plans or user-imported templates.

### 4. Move navigation responsibility into a shell screen with a real second-tab destination
The current home screen owns the bottom nav but does not actually swap content. Implementation should introduce an app shell that hosts the bottom navigation and uses an `IndexedStack` or equivalent persistent tab container. The second destination becomes the plan library, where users can preview plans and switch the active plan directly.

This avoids pushing the plan library as a side-route from Home for the main use case and keeps tab state stable across navigation.

Alternative considered:
- Keep the home card as the primary plan entry point. Rejected because the request explicitly assigns this responsibility to the second bottom-nav item.

### 5. Today’s workout becomes “active plan aware,” not “default GZCLP aware”
The today-workout gateway will resolve its summary and resumable session from the active instance pointer. If the user switches from GZCLP to Jacked & Tan, the dashboard hero card must immediately reflect the newly active plan’s current workout without requiring a restart or reseed.

## Risks / Trade-offs

- [Risk] Jacked & Tan workbook semantics include custom week blocks, test weeks, and deload notes that may not map cleanly onto the current simplified plan model.  
  Mitigation: Preserve the workbook’s week-to-week loading scheme where it fits the existing model and explicitly normalize any unsupported notes in the asset generation step.

- [Risk] Switching active plans could confuse users if historical logs and in-progress sessions appear to disappear.  
  Mitigation: Switch instances without deleting prior logs, show an active-plan indicator in the library, and treat switching as changing the current training context rather than replacing stored history.

- [Risk] The set-budget calculation depends on direct-set accounting conventions.  
  Mitigation: Encode the selected movement mix explicitly in the spec and use the stated muscle-group accounting method in tests and seed validation.

- [Risk] Shell-level navigation refactoring can break existing widget assumptions.  
  Mitigation: Keep tab content screens focused, move bottom-nav state to a dedicated shell, and add widget tests for tab routing and plan switching.

## Migration Plan

1. Add the Jacked & Tan JSON asset and seed loader beside the existing GZCLP asset flow.
2. Introduce persistent active-instance storage and migrate bootstrap to set a sensible default if none exists.
3. Refactor the bottom nav into a shell screen and route the second tab to the plan library.
4. Update today-workout loading to read the active instance pointer.
5. Verify plan export/import still works with both built-in templates and switched custom plans.

## Open Questions

- The workbook contains later testing/deload sections beyond the first weekly block; implementation should confirm whether the existing rule model can encode every later-week nuance directly or whether a normalized but behaviorally equivalent representation is required.
