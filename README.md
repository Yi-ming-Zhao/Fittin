# Fittin

Fittin is a Flutter strength training app focused on low-friction workout logging, structured program templates, and a premium mobile-first training experience.

This repository is the active product codebase for the second-generation app prototype. The project is guided by OpenSpec documents in `openspec/specs/`, and the current implementation already covers the core loop from selecting a plan to starting today's workout and tracking progress over time.

## Current Product Scope

Implemented and actively represented in the app:

- Home dashboard with a "Today's Workout" hero entry point
- Active training session flow for multi-exercise workouts
- Gesture-first set logging direction for the active session UI
- Plan library with built-in and custom templates
- In-app plan template editor
- Progress analytics screen
- English / Chinese language switching
- Local-first persistence with seeded training plans
- Share/export-related app foundations

OpenSpec themes currently shaping the product:

- A compact zero-typing workout logger
- Premium minimal frontend redesign work
- Progress analytics hierarchy and presentation upgrades
- Training log screen refactor
- Template editing and plan switching improvements

## Product Direction

Fittin is aiming for a workout experience that feels closer to a focused training console than a form-heavy gym tracker:

- Fast logging with large touch targets and minimal keyboard dependence
- Strong visual hierarchy for today's workout, current set, and progress
- Structured training logic for reusable strength programs
- Bilingual UX designed to stay clear in both English and Chinese

## Tech Stack

- Flutter
- Dart 3.9
- Riverpod for state management
- Isar for local database storage
- Freezed + JSON Serializable for models

## Project Structure

```text
lib/
  main.dart
  src/
    application/   # providers and app services
    data/          # local database + seeded templates
    domain/        # models, rule engine, progression logic
    presentation/  # screens, widgets, theme, localization
test/              # widget, application, domain, and data tests
openspec/specs/    # product requirements and design direction
```

## Built-In Training Content

The app currently ships with seeded program assets including:

- GZCLP
- Jacked & Tan 2.0

These templates can be loaded locally and used as the base for switching plans or creating custom variants.

## Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK matching the Flutter toolchain
- A supported iOS simulator, Android emulator, or physical device

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### Run tests

```bash
flutter test
```

## OpenSpec Workflow

This repository uses OpenSpec to track product requirements and UI/UX direction. The specs in `openspec/specs/` describe both implemented functionality and active design changes in progress.

If you are reviewing the project, treat the specs as the product contract and the Flutter code as the current implementation snapshot.

## Status

Fittin is currently an actively evolving product prototype. Some specs describe work that is already implemented, while others document the next iteration of the interface and training flow.
