## Context

The app already has two built-in programs, JSON-based templates, editable custom templates, and one runtime evaluation path that assumes the next workout is mostly determined by the previous workout's outcome. That is sufficient for a simplified GZCLP implementation, but it is not sufficient for the actual programs the user wants:
- GZCLP is a linear progression plan whose prescribed load advances or resets based on success/failure while still starting from training-max-derived values.
- Jacked & Tan 2.0 is a periodized block plan whose week-to-week prescriptions are fixed by the cycle and derived from training max percentages; a logged session must not rewrite the next week's planned weights just because the prior week was easy or hard.

The current built-in JSON assets also hard-code starting weights, which is incompatible with the original spreadsheets and the referenced guides. Both programs are supposed to start from user-entered training max values and then derive working weights from those values. The existing plan editor also assumes one generalized runtime shape, so this change should preserve runtime correctness first and avoid forcing a fake "one engine fits all" abstraction if it obscures the real programming differences.

Reference constraints:
- Exercise selection still comes from the checked-in Excel files: [2.0_GZCLP 4-Day 12-Week.xlsx](/Users/yzxbb/Desktop/Fittin_v2/2.0_GZCLP%204-Day%2012-Week.xlsx) and [jacked_and_tan.xlsx](/Users/yzxbb/Desktop/Fittin_v2/jacked_and_tan.xlsx).
- Program principles come from the referenced GZCLP and Jacked & Tan guides.
- Existing workout logs and active-instance behavior must remain deterministic and local-first.

## Goals / Non-Goals

**Goals:**
- Make both built-in programs training-max-driven instead of fixed-weight-driven.
- Separate linear and periodized runtime behavior so GZCLP and Jacked & Tan are modeled honestly.
- Preserve one shared top-level template envelope where practical, but allow engine-specific payloads when the data shape truly differs.
- Require a training-max setup step before the first instance of either built-in program is created.
- Persist enough engine state to reproduce future prescriptions exactly for both program types.

**Non-Goals:**
- Rebuild the in-app plan editor so users can fully author linear and periodized engine payloads in this change.
- Add cloud sync or cross-device plan state reconciliation.
- Implement every possible GZCL derivative program family; this change covers the built-in GZCLP and Jacked & Tan 2.0 implementations only.
- Treat Jacked & Tan as autoregulated week-to-week progression beyond what its workbook and guide define.

## Decisions

### 1. Use a shared template envelope with engine-family-specific payloads
Each plan template will keep the existing high-level identity and workout hierarchy, but it will declare an `engineFamily` and include engine-specific prescription metadata:
- `linear_tm` for GZCLP
- `periodized_tm` for Jacked & Tan 2.0

The shared envelope keeps template listing, sharing, and storage coherent. The engine-specific payload avoids contorting Jacked & Tan into the current rule-action ladder used for GZCLP.

Rationale:
- preserves the existing JSON-first architecture
- avoids maintaining two completely unrelated template transport formats
- keeps runtime honest about the fact that GZCLP and J&T are not the same progression model

Alternative considered:
- One generalized schema with optional fields for every program type. Rejected because it would make every template harder to validate and still leave the rule engine full of conditional branches.
- Two fully separate top-level JSON formats. Rejected because it complicates storage, sharing, and editor/listing infrastructure more than necessary.

### 2. Split runtime evaluation into two engines behind one dispatcher
The current rule engine behavior should evolve into a dispatcher:
- `LinearProgramEngine` resolves GZCLP prescriptions, applies success/failure logic, progresses T1/T2 schemes, and handles resets.
- `PeriodizedProgramEngine` resolves J&T prescriptions from the current week/block and training max, advances the period cursor after a workout, and does not mutate future prescribed weights via linear carry-forward.

`plan-rule-engine` remains the public capability, but implementation should stop pretending that one evaluation algorithm can cleanly govern both families.

Rationale:
- GZCLP and J&T differ in what a completed workout is supposed to change
- periodized weeks need deterministic reproduction from cycle state, not ad hoc progression
- engine-specific testing becomes much clearer

Alternative considered:
- Keep one engine and encode periodization as more rules. Rejected because J&T week/block scheduling is prescription selection, not just rule evaluation after logging.

### 3. Training max becomes first-class instance input, not a derived afterthought
Starting a new built-in plan instance should require a training-max setup form. The instance stores a `trainingMaxProfile` keyed by canonical lift IDs (for example squat, bench, deadlift, overhead_press), plus any program-specific mappings required for derived exercises.

Exercise prescriptions are then resolved from:
- the program template's lift mapping and percentage tables
- the user's TM profile
- the instance engine state (scheme stage for GZCLP, week/block cursor for J&T)
- rounding rules/increments

Rationale:
- this matches how both source programs are designed
- it eliminates brittle hard-coded seed constants
- it makes resets and future cycle restarts reproducible

Alternative considered:
- Ask for working weights per exercise and back-compute TM. Rejected because the user explicitly wants TM to be the source of truth and because program calculations become harder to explain.

### 4. GZCLP should remain a linear progression instance with TM-based initialization
The built-in GZCLP template will still encode its familiar T1/T2 ladders and reset behavior, but it should no longer seed final starting weights from the workbook. Instead:
- activation derives starting working weights from TM input and template-defined starter percentages or workbook-equivalent initialization values
- T1 applies upper/lower increments, scheme changes, and reset behavior
- T2 applies its 3x10 -> 3x8 -> 3x6 ladder and reset behavior
- T3 remains non-engine-driving assistance

This preserves the program's linear nature while aligning it with the user's TM-first requirement.

### 5. Jacked & Tan should be rebuilt as a fixed weekly prescription schedule
The built-in J&T template must encode its week-by-week structure explicitly. The instance engine state stores at least:
- current block/week index
- current workout rotation position
- training max profile

For any scheduled workout, the app computes prescribed weights from TM and the week-specific percentage table defined by the rebuilt asset. Completing a workout advances the cursor to the next scheduled slot; it does not alter the next week's prescribed percentages.

Performance data still matters for logs and potentially for user review, but it does not act as a linear progression driver for future weekly loads in this change.

### 6. Plan activation owns TM setup for new instances
The plan library activation flow should behave as follows:
- if a template already has an instance, reuse it
- if not, prompt for the TM profile required by that template
- create the instance only after TM input is complete
- set that instance active

This keeps onboarding tied to plan creation, avoids half-configured active plans, and lets different programs request different lift keys if needed.

Alternative considered:
- global app-wide TM settings. Rejected because users may run different plans with different TMs or update one plan's TMs without rewriting another instance.

## Risks / Trade-offs

- [Risk] Engine-family-specific payloads make custom template editing less uniform.  
  Mitigation: explicitly keep full authoring support out of scope for this change and prioritize built-in runtime correctness.

- [Risk] Rebuilding J&T from the workbook and guide may expose places where the current session model assumes static per-exercise weights.  
  Mitigation: treat prescription resolution as a separate step before session creation and keep raw logs distinct from future schedule state.

- [Risk] Users may expect failed J&T sessions to auto-adjust future prescribed weeks.  
  Mitigation: document J&T as fixed weekly periodization in the spec and keep future-week load calculation anchored to TM plus week tables.

- [Risk] TM-driven initialization may invalidate assumptions in older tests and seeds.  
  Mitigation: regenerate both built-in assets and add engine-specific tests for initial prescription math, progression, and cursor advancement.

- [Risk] GZCLP source materials describe starting from estimated working values while the user wants TM-based setup.  
  Mitigation: normalize built-in GZCLP activation around explicit TM input and make starter percentage logic part of the template/engine contract rather than a hidden seed constant.

## Migration Plan

1. Introduce `engineFamily`, training-max profile storage, and engine-state persistence at the domain/storage layer.
2. Rebuild the built-in GZCLP and J&T JSON assets around TM-driven metadata instead of fixed working weights.
3. Implement the engine dispatcher plus linear and periodized engine paths.
4. Add TM setup to first-time plan activation.
5. Update session creation to resolve prescribed weights at launch time from TM + engine state.
6. Verify that both plans remain exportable, seed correctly on empty storage, and survive app restarts without losing period/linear state.

Rollback strategy:
- preserve the archive of current assets/specs while replacing only the active built-in assets
- keep the shared template envelope stable so storage rollback is limited to engine-family fields and seed defaults

## Open Questions

- How much of the built-in template editor should expose engine-family-specific metadata in the first implementation, if any?
- Should the app support editing TM values mid-cycle for an existing instance, or should that require starting a fresh instance in this change?
- For J&T assistance tiers that are described differently in the guide and spreadsheet, should the spreadsheet remain the authoritative source for built-in prescriptions wherever the two differ?
