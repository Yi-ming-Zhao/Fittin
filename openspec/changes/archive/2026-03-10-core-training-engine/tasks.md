## 1. Project Initialization & Setup

- [x] 1.1 Initialize a new Flutter project (e.g. `fittin_v2`) using `flutter create`.
- [x] 1.2 Add dependencies in `pubspec.yaml` for: `isar`, `isar_flutter_libs`, `flutter_riverpod`, `freezed_annotation`, `json_annotation`.
- [x] 1.3 Add dev_dependencies for: `build_runner`, `isar_generator`, `freezed`, `json_serializable`.
- [x] 1.4 Setup project directory structure (e.g., `lib/src/domain`, `lib/src/data`, `lib/src/presentation`).

## 2. Core Rule Engine (Domain Layer)

- [x] 2.1 Define Dart structs/PODOs for core models: `PlanTemplate`, `Phase`, `Workout`, `Exercise`, `SetScheme`.
- [x] 2.2 Define the `ProgressionRule` schema (Conditions & Actions interface definitions).
- [x] 2.3 Implement the `RuleEngine` class with a parser to deserialize JSON into the `PlanTemplate` object.
- [x] 2.4 Implement `RuleEngine.evaluateNextWorkout()` method to calculate the next session state based on `currentState`, `todayLog`, and `rules`.
- [x] 2.5 Write unit tests for `RuleEngine` to cover "success -> weight ++" and "failure -> stage jump" logic.

## 3. Local Database & Models (Data Layer)

- [x] 3.1 Define Isar collection models for `TemplateCollection` (storing static JSON string or parsed tree).
- [x] 3.2 Define Isar collection models for `InstanceCollection` (linking to a template, storing user's current stage, base TM, etc.).
- [x] 3.3 Define Isar collection models for `WorkoutLogCollection` (daily executed sets and reps).
- [x] 3.4 Run `build_runner` to generate `.g.dart` schema files for Isar and Freezed.
- [x] 3.5 Implement `DatabaseRepository` providing abstraction for CRUD operations towards `Isar` DB.

## 4. Training Session Logic (Application/State Layer)

- [x] 4.1 Create Riverpod Providers/Notifiers to manage the state of the active training `Instance`.
- [x] 4.2 Create a state notifier to handle real-time set modifications during an evaluation (modifying completed reps/weight).
- [x] 4.3 Create a "Conclude Session" function that passes data down to the repository and invokes `RuleEngine` to sync the newly created instance state back to Isar.

## 5. Workout UI (Presentation Layer) -> Zero-Typing UI

- [x] 5.1 Implement the `ActiveSessionScreen` UI layout (header, exercise selector, sets list).
- [x] 5.2 Build a `SetInputRow` widget that auto-populates values from the state's calculated targets.
- [x] 5.3 Implement the pan gesture (`GestureDetector` horizontally) on `SetInputRow` to increase/decrease numerical values cleanly. 
- [x] 5.4 Build and integrate a global floating timer widget that starts upon a set's checkmark action.

## 6. Sharing / P2P Module

- [x] 6.1 Implement `ExportService` to serialize `PlanTemplate` into a base64 encoded compact JSON.
- [x] 6.2 Add a package (like `qr_flutter`) to render the localized base64 string as a QR code in a `ShareScreen`.
- [x] 6.3 Add a package (like `mobile_scanner`) to provide a UI module for scanning QRs and routing decoding logic to the `RuleEngine`.
