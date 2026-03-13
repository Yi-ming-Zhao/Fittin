## 1. Program Model and Storage

- [x] 1.1 Extend the template and instance models to declare an engine family, exercise-to-lift TM mappings, engine-specific payloads, and persisted training-max profiles.
- [x] 1.2 Add storage schema and repository support for engine-family state, including linear progression state and periodized week/block cursors.
- [x] 1.3 Add migration/bootstrap handling so existing built-in templates are replaced by TM-driven GZCLP and Jacked & Tan seeds without breaking user-owned templates.

## 2. Training Max Setup

- [x] 2.1 Build a training-max setup flow that is triggered when activating a built-in TM-driven plan that does not yet have an instance.
- [x] 2.2 Implement canonical lift-key mapping and rounding helpers so derived exercise prescriptions can be calculated from a stored TM profile.
- [x] 2.3 Ensure reusing an existing instance skips setup and preserves the original TM profile and engine state.

## 3. Engine Implementation

- [x] 3.1 Refactor the current rule engine entry point into an engine dispatcher that routes `linear_tm` and `periodized_tm` instances to dedicated evaluators.
- [x] 3.2 Implement the linear GZCLP evaluator for TM-derived initialization, tier-specific increments, stage changes, and reset behavior.
- [x] 3.3 Implement the periodized Jacked & Tan evaluator for week/block prescription lookup and schedule advancement without linear carry-forward.
- [x] 3.4 Update session creation so set weights are resolved from TM plus engine state at launch time instead of from fixed seeded working weights.

## 4. Built-in Program Assets

- [x] 4.1 Rebuild the built-in GZCLP asset from the Excel workbook and guide so exercise selection comes from the workbook while prescriptions are generated from TM metadata.
- [x] 4.2 Rebuild the built-in Jacked & Tan asset from the Excel workbook and guide so weekly prescriptions are fixed by the periodized schedule and generated from TM metadata.
- [x] 4.3 Validate that the rebuilt assets preserve the approved exercise selections and encode the intended lift mappings and progression family for each program.

## 5. Verification

- [x] 5.1 Add unit tests for TM-based prescription math, lift mapping, and persisted engine-state restoration.
- [x] 5.2 Add engine tests that prove GZCLP changes future load via linear progression while Jacked & Tan preserves fixed next-week prescriptions.
- [x] 5.3 Add integration/widget tests for first-time plan activation with TM setup, existing-instance reuse, and session loading with computed weights.
- [x] 5.4 Run the relevant automated tests and verify both rebuilt built-in plans still serialize and remain shareable through the existing JSON/QR flow.
