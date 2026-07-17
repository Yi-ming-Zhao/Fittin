## ADDED Requirements

### Requirement: Palette-Aware Startup Transition
The system MUST provide a restrained branded startup transition that uses the resolved semantic palette, communicates preparation without fake percentage progress, and hands off smoothly to the ready app shell.

#### Scenario: App performs readiness work
- **WHEN** startup restoration or hydration is still in progress
- **THEN** a localized abstract-barbell animation is shown using the selected palette's canvas, content, structure, and accent roles
- **AND** no cyan or teal fallback color appears.

#### Scenario: Reduced motion is requested
- **WHEN** the platform indicates that animations should be disabled or reduced
- **THEN** the startup mark remains visible with a static or minimal-opacity treatment
- **AND** readiness and recovery behavior remain unchanged.
