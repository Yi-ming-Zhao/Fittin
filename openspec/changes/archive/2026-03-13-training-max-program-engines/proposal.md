## Why

The app currently treats GZCLP and Jacked & Tan as if they can share the same progression logic and static-weight JSON model, which is incorrect. GZCLP is a training-max-driven linear progression with failures, resets, and scheme changes, while Jacked & Tan 2.0 is a training-max-driven periodized plan whose weekly prescriptions are fixed by block and must not be overwritten by linear carry-forward logic.

## What Changes

- Replace hard-coded starting weights in the built-in GZCLP and Jacked & Tan templates with training-max-driven prescriptions derived from the checked-in Excel files and the referenced GZCL guides.
- Add a first-class training-max setup flow so users enter plan-specific training max values before the app creates a new training instance.
- Extend the program engine contract so the app can resolve both linear and periodized plans instead of forcing Jacked & Tan through the existing linear rule engine.
- **BREAKING**: Built-in template JSON for GZCLP and Jacked & Tan will no longer encode runtime starting weights as fixed values; runtime prescriptions will be calculated from training max plus engine metadata.
- Persist engine-family state, training-max profiles, and period/block cursors separately from workout logs so future prescriptions can be reproduced deterministically.

## Capabilities

### New Capabilities
- `training-max-setup`: collects user training max values when activating a program and derives exercise prescriptions from those values.

### Modified Capabilities
- `plan-rule-engine`: add engine-family-aware prescription resolution for linear and periodized plans instead of one shared progression path.
- `gzclp-program-template`: redefine built-in GZCLP around training-max-derived linear progression and workbook-guided exercise selection.
- `jacked-and-tan-program-template`: redefine built-in Jacked & Tan around training-max-derived weekly periodization rather than linear progression.
- `local-datastore-schema`: persist training-max profiles, engine metadata, and engine state required to reproduce future prescriptions.
- `plan-library-switching`: require training-max setup before the first instance of a plan is created and activated.

## Impact

- Affected code spans template JSON assets, plan parsing, rule/program engine services, instance persistence, and plan activation UX.
- Existing built-in seed data for GZCLP and Jacked & Tan must be regenerated from the Excel files.
- The active session loading path will need to consume computed prescriptions instead of assuming static stored working weights.
