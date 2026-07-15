import 'dart:collection';

import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';

enum PerformanceConfidence { unavailable, low, medium, high }

extension PerformanceConfidenceX on PerformanceConfidence {
  int get rank => index;

  PerformanceConfidence capAt(PerformanceConfidence ceiling) {
    return rank <= ceiling.rank ? this : ceiling;
  }
}

class PerformanceSetSource {
  const PerformanceSetSource({
    required this.logId,
    required this.instanceId,
    required this.workoutId,
    required this.workoutName,
    required this.completedAt,
    required this.setIndex,
    required this.setRole,
    required this.weightKg,
    required this.completedReps,
  });

  final String logId;
  final String instanceId;
  final String workoutId;
  final String workoutName;
  final DateTime completedAt;
  final int setIndex;
  final String setRole;
  final double weightKg;
  final int completedReps;

  String get workoutReference {
    if (logId.trim().isNotEmpty) {
      return logId;
    }
    return '$instanceId/$workoutId/${completedAt.toUtc().toIso8601String()}';
  }

  String get stableKey {
    return '${completedAt.toUtc().toIso8601String()}|$workoutReference|'
        '$setIndex|$setRole|$weightKg|$completedReps';
  }
}

class ObservedRepMax {
  const ObservedRepMax({
    required this.reps,
    required this.weightKg,
    required this.source,
  });

  final int reps;
  final double weightKg;
  final PerformanceSetSource source;

  PerformanceConfidence get confidence => PerformanceConfidence.high;
}

class OneRepMaxRecord {
  const OneRepMaxRecord({
    required this.valueKg,
    required this.isActual,
    required this.formula,
    required this.confidence,
    required this.source,
  });

  final double valueKg;
  final bool isActual;
  final OneRepMaxFormula? formula;
  final PerformanceConfidence confidence;
  final PerformanceSetSource source;
}

class ExercisePerformanceProfile {
  ExercisePerformanceProfile({
    required this.exerciseId,
    required this.sourceDisplayName,
    required Map<int, ObservedRepMax> observedRepMaxByReps,
    required this.actualOneRepMax,
    required this.estimatedOneRepMax,
    required this.requiresEquipmentCalibration,
    required this.isBodyweightOnly,
  }) : observedRepMaxByReps = Map.unmodifiable(
         SplayTreeMap<int, ObservedRepMax>.of(observedRepMaxByReps),
       );

  final String exerciseId;
  final String sourceDisplayName;
  final Map<int, ObservedRepMax> observedRepMaxByReps;
  final OneRepMaxRecord? actualOneRepMax;
  final OneRepMaxRecord? estimatedOneRepMax;
  final bool requiresEquipmentCalibration;
  final bool isBodyweightOnly;

  ObservedRepMax? observedRepMax(int reps) => observedRepMaxByReps[reps];
}

class ExercisePerformanceProfileProjection {
  ExercisePerformanceProfileProjection({
    required this.catalogVersion,
    required this.formula,
    required this.sourceFingerprint,
    required Map<String, ExercisePerformanceProfile> profiles,
  }) : profiles = Map.unmodifiable(
         SplayTreeMap<String, ExercisePerformanceProfile>.of(profiles),
       );

  final String catalogVersion;
  final OneRepMaxFormula formula;
  final String sourceFingerprint;
  final Map<String, ExercisePerformanceProfile> profiles;

  ExercisePerformanceProfile? operator [](String exerciseId) {
    return profiles[exerciseId];
  }
}

class ExercisePerformanceProfileService {
  const ExercisePerformanceProfileService();

  static const int maximumEstimatedReps = 10;

  ExercisePerformanceProfileProjection build({
    required List<WorkoutLog> logs,
    required ExerciseLibrary library,
    OneRepMaxFormula formula = OneRepMaxFormula.epley,
  }) {
    final builders = <String, _ProfileBuilder>{};

    for (final log in logs) {
      for (final exercise in log.exercises) {
        final resolved = _resolveExercise(library, exercise);
        if (resolved.isSelectionSlot) {
          continue;
        }

        for (var setIndex = 0; setIndex < exercise.sets.length; setIndex++) {
          final set = exercise.sets[setIndex];
          if (!_isValidObservedSet(set)) {
            continue;
          }

          final source = PerformanceSetSource(
            logId: log.logId,
            instanceId: log.instanceId,
            workoutId: log.workoutId,
            workoutName: log.workoutName,
            completedAt: log.completedAt,
            setIndex: setIndex,
            setRole: set.role,
            weightKg: set.weight,
            completedReps: set.completedReps,
          );
          final builder = builders.putIfAbsent(
            resolved.id,
            () => _ProfileBuilder(resolved.id),
          );
          builder.recordLoadPolicy(resolved, exercise);
          builder.recordDisplayName(exercise.exerciseName, source);
          builder.recordObserved(set, source);

          if (!_isEligibleForOneRepMax(resolved, exercise)) {
            continue;
          }

          if (set.completedReps == 1) {
            builder.recordActualOneRepMax(
              set.weight,
              _actualConfidence(resolved, exercise),
              source,
            );
            continue;
          }
          if (set.completedReps > maximumEstimatedReps) {
            continue;
          }

          final estimated = estimateOneRepMax(
            formula: formula,
            weight: set.weight,
            reps: set.completedReps,
          );
          if (estimated == null || !estimated.isFinite || estimated <= 0) {
            continue;
          }
          builder.recordEstimatedOneRepMax(
            estimated,
            formula,
            _estimatedConfidence(resolved, exercise, set.completedReps),
            source,
          );
        }
      }
    }

    final profiles = {
      for (final entry in builders.entries) entry.key: entry.value.build(),
    };
    return ExercisePerformanceProfileProjection(
      catalogVersion: library.catalogVersion,
      formula: formula,
      sourceFingerprint: _profileFingerprint(profiles, formula),
      profiles: profiles,
    );
  }
}

String _profileFingerprint(
  Map<String, ExercisePerformanceProfile> profiles,
  OneRepMaxFormula formula,
) {
  final parts = <String>['formula=${formula.key}'];
  final exerciseIds = profiles.keys.toList()..sort();
  for (final exerciseId in exerciseIds) {
    final profile = profiles[exerciseId]!;
    parts.add('exercise=$exerciseId');
    for (final observed in profile.observedRepMaxByReps.values) {
      parts.add(
        '${observed.reps}:${observed.weightKg}:'
        '${observed.source.stableKey}',
      );
    }
  }

  var hash = 0x811c9dc5;
  for (final codeUnit in parts.join('|').codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

ResolvedExercise _resolveExercise(
  ExerciseLibrary library,
  ExerciseLog exercise,
) {
  final definitionId = exercise.exerciseDefinitionId.trim();
  if (definitionId.isNotEmpty) {
    if (definitionId.startsWith('custom:')) {
      return library.resolve(exerciseId: definitionId, name: '');
    }
    final resolvedDefinition = library.resolve(
      exerciseId: definitionId,
      name: exercise.exerciseName,
    );
    if (!resolvedDefinition.isCustom) {
      return resolvedDefinition;
    }

    final legacy = library.findKnown(
      exerciseId: exercise.exerciseId,
      name: exercise.exerciseName,
    );
    if (legacy != null) {
      return library.resolve(
        exerciseId: legacy.id,
        name: exercise.exerciseName,
      );
    }
    return resolvedDefinition;
  }
  return library.resolve(
    exerciseId: exercise.exerciseId,
    name: exercise.exerciseName,
  );
}

bool _isValidObservedSet(SetLog set) {
  return set.isCompleted &&
      set.completedReps > 0 &&
      set.weight > 0 &&
      set.weight.isFinite;
}

bool _isEligibleForOneRepMax(ResolvedExercise resolved, ExerciseLog exercise) {
  final semantics = resolved.definition?.loadSemantics;
  if (semantics == ExerciseLoadSemantics.bodyweight ||
      semantics == ExerciseLoadSemantics.bandResistance ||
      semantics == ExerciseLoadSemantics.selection) {
    return false;
  }
  return exercise.displayLoadUnit != LoadUnits.bodyweight;
}

PerformanceConfidence _actualConfidence(
  ResolvedExercise resolved,
  ExerciseLog exercise,
) {
  final definition = resolved.definition;
  if (definition == null) {
    return exercise.displayLoadUnit == LoadUnits.cableStack
        ? PerformanceConfidence.low
        : PerformanceConfidence.medium;
  }
  if (definition.equipment == ExerciseEquipment.machine ||
      definition.equipment == ExerciseEquipment.cable) {
    return PerformanceConfidence.low;
  }
  return PerformanceConfidence.high;
}

PerformanceConfidence _estimatedConfidence(
  ResolvedExercise resolved,
  ExerciseLog exercise,
  int reps,
) {
  var confidence = reps <= 5
      ? PerformanceConfidence.medium
      : PerformanceConfidence.low;
  final definition = resolved.definition;
  if (definition == null) {
    return confidence.capAt(
      exercise.displayLoadUnit == LoadUnits.cableStack
          ? PerformanceConfidence.low
          : PerformanceConfidence.medium,
    );
  }
  if (definition.equipment == ExerciseEquipment.machine ||
      definition.equipment == ExerciseEquipment.cable ||
      definition.loadSemantics ==
          ExerciseLoadSemantics.bodyweightPlusExternal) {
    confidence = confidence.capAt(PerformanceConfidence.low);
  } else if (definition.equipment == ExerciseEquipment.dumbbell ||
      definition.equipment == ExerciseEquipment.mixed) {
    confidence = confidence.capAt(PerformanceConfidence.medium);
  }
  return confidence;
}

class _ProfileBuilder {
  _ProfileBuilder(this.exerciseId);

  final String exerciseId;
  final Map<int, ObservedRepMax> _observed = {};
  String _displayName = '';
  PerformanceSetSource? _displayNameSource;
  OneRepMaxRecord? _actual;
  OneRepMaxRecord? _estimated;
  bool _requiresEquipmentCalibration = false;
  bool _isBodyweightOnly = false;

  void recordLoadPolicy(ResolvedExercise resolved, ExerciseLog exercise) {
    final definition = resolved.definition;
    _requiresEquipmentCalibration |=
        definition?.equipment == ExerciseEquipment.machine ||
        definition?.equipment == ExerciseEquipment.cable ||
        definition?.loadSemantics == ExerciseLoadSemantics.machineStack ||
        definition?.loadSemantics == ExerciseLoadSemantics.cableStack ||
        exercise.displayLoadUnit == LoadUnits.cableStack;
    _isBodyweightOnly |=
        definition?.loadSemantics == ExerciseLoadSemantics.bodyweight ||
        exercise.displayLoadUnit == LoadUnits.bodyweight;
  }

  void recordDisplayName(String value, PerformanceSetSource source) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final currentSource = _displayNameSource;
    if (currentSource == null || _isLaterSource(source, currentSource)) {
      _displayName = trimmed;
      _displayNameSource = source;
    }
  }

  void recordObserved(SetLog set, PerformanceSetSource source) {
    final candidate = ObservedRepMax(
      reps: set.completedReps,
      weightKg: set.weight,
      source: source,
    );
    final current = _observed[set.completedReps];
    if (current == null ||
        _isBetterValueAndSource(
          candidate.weightKg,
          candidate.source,
          current.weightKg,
          current.source,
        )) {
      _observed[set.completedReps] = candidate;
    }
  }

  void recordActualOneRepMax(
    double valueKg,
    PerformanceConfidence confidence,
    PerformanceSetSource source,
  ) {
    final candidate = OneRepMaxRecord(
      valueKg: valueKg,
      isActual: true,
      formula: null,
      confidence: confidence,
      source: source,
    );
    if (_actual == null ||
        _isBetterValueAndSource(
          candidate.valueKg,
          candidate.source,
          _actual!.valueKg,
          _actual!.source,
        )) {
      _actual = candidate;
    }
  }

  void recordEstimatedOneRepMax(
    double valueKg,
    OneRepMaxFormula formula,
    PerformanceConfidence confidence,
    PerformanceSetSource source,
  ) {
    final candidate = OneRepMaxRecord(
      valueKg: valueKg,
      isActual: false,
      formula: formula,
      confidence: confidence,
      source: source,
    );
    if (_estimated == null ||
        _isBetterValueAndSource(
          candidate.valueKg,
          candidate.source,
          _estimated!.valueKg,
          _estimated!.source,
        )) {
      _estimated = candidate;
    }
  }

  ExercisePerformanceProfile build() {
    return ExercisePerformanceProfile(
      exerciseId: exerciseId,
      sourceDisplayName: _displayName.isEmpty ? exerciseId : _displayName,
      observedRepMaxByReps: _observed,
      actualOneRepMax: _actual,
      estimatedOneRepMax: _estimated,
      requiresEquipmentCalibration: _requiresEquipmentCalibration,
      isBodyweightOnly: _isBodyweightOnly,
    );
  }
}

bool _isBetterValueAndSource(
  double candidateValue,
  PerformanceSetSource candidateSource,
  double currentValue,
  PerformanceSetSource currentSource,
) {
  final valueComparison = candidateValue.compareTo(currentValue);
  if (valueComparison != 0) {
    return valueComparison > 0;
  }
  return _isLaterSource(candidateSource, currentSource);
}

bool _isLaterSource(
  PerformanceSetSource candidate,
  PerformanceSetSource current,
) {
  final dateComparison = candidate.completedAt.compareTo(current.completedAt);
  if (dateComparison != 0) {
    return dateComparison > 0;
  }
  return candidate.stableKey.compareTo(current.stableKey) > 0;
}
