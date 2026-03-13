## ADDED Requirements

### Requirement: JSON Schema Parsing
The system MUST parse training plan templates from a predefined JSON schema into internal Dart objects, preserving the hierarchy of phases, workouts, exercises, and sets.

#### Scenario: Valid JSON parsing
- **WHEN** a valid JSON template string is provided
- **THEN** the engine parses it into a strongly-typed `PlanTemplate` object without errors

### Requirement: Progression Outcome Evaluation
The system MUST evaluate the log of a completed exercise session against the rules defined in the plan template to determine the state of the exercise for the next session.

#### Scenario: Successful completion leads to progression
- **WHEN** the user meets or exceeds the target reps for all sets in an exercise And the rule dictates adding weight on success
- **THEN** the engine returns a new state with the weight increased by the configured increment and the same set/rep scheme

#### Scenario: Failure leads to regression
- **WHEN** the user fails to meet the target reps in one or more sets And the rule dictates changing the scheme on failure
- **THEN** the engine returns a new state with the same weight but transitioning to the next specified set/rep scheme (e.g., from 5x3 to 6x2)
