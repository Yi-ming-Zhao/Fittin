## MODIFIED Requirements

### Requirement: Focused Workout Console Composition
The active workout experience MUST present the current exercise and current set as the dominant focal element in a console-style layout.

For the compact logger refactor, this composition MUST be compressed enough to fit the essential recording flow within a single mobile viewport and MUST avoid oversized preview modules that push controls below the fold.

#### Scenario: Logging a working set on mobile
- **WHEN** the user opens the refactored workout logger
- **THEN** the exercise preview is compact, the current-set controls remain above the fold, and the page reads as one coherent console instead of a long stacked screen.

### Requirement: Reference-Inspired but App-Native Workout Interaction
The workout console MAY draw interaction inspiration from focused gym logging apps, but it MUST remain consistent with the app's own data model, bilingual support, and current training flow.

The refactor MUST use a compact exercise-switch action with premium dropdown animation rather than reproducing a large separate exercise rail from earlier iterations.

#### Scenario: Switching to another exercise
- **WHEN** the user invokes the compact exercise-switch control
- **THEN** the transition feels polished and premium, but the result still uses the app's existing workout/session model and localized exercise names.

### Requirement: Premium Editor Mode Separation
The premium minimal redesign MUST give the plan editor distinct visual structures for linear-plan editing and periodized day-slot editing instead of rendering the entire cycle as one uninterrupted dark form.

#### Scenario: User edits a periodized plan on mobile
- **WHEN** the user opens a periodized template such as Jacked & Tan
- **THEN** the interface presents an intentional week/day selection surface such as `W1D1`
- **AND** the chosen slot opens into a focused premium editor rather than a flattened full-cycle scroll.

### Requirement: Premium Set-Type Selection
The plan editor MUST render set-type choice as a deliberate premium selection control with short explanatory text, not as a lone AMRAP toggle.

#### Scenario: User chooses a set category
- **WHEN** the user edits a set inside the plan editor
- **THEN** the set-type control presents structured options such as `top set` or `AMRAP set` in a visually intentional premium selector with clear selected state.

### Requirement: Premium Subpage Back Affordance
The premium minimal redesign MUST give secondary pages a consistent back-navigation affordance that matches the app's premium visual language instead of relying on inconsistent default headers or leaving pages without a visible return action.

#### Scenario: User opens a premium-styled subpage
- **WHEN** the user navigates to a secondary page with custom or premium header styling
- **THEN** the page shows a deliberate back icon treatment that feels visually integrated with the rest of the interface
- **AND** the icon remains easy to discover on both mobile and macOS layouts.
