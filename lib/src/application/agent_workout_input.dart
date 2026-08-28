import '../domain/models/workout_log.dart';

/// Model-facing edits never deserialize the persistence model directly.
abstract final class AgentWorkoutInput {
  static const fields = {'completedAt', 'exercises'};
  static const exerciseFields = {'exerciseId', 'sets'};
  static const setFields = {
    'completedReps',
    'weight',
    'completedRpe',
    'isSkipped',
    'isCompleted',
  };

  static Map<String, dynamic> object(Object? value, Set<String> allowed) {
    if (value is! Map<String, dynamic> ||
        value.keys.any((k) => !allowed.contains(k))) {
      throw const FormatException(
        'Unsupported workout fields. Only editable workout values are accepted; IDs, snapshots and sync metadata are read-only.',
      );
    }
    return value;
  }

  static WorkoutLog apply(Object? input, WorkoutLog trusted) {
    final map = object(input, fields);
    final date = map.containsKey('completedAt')
        ? DateTime.parse(map['completedAt'] as String)
        : trusted.completedAt;
    if (date.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      throw const FormatException(
        'Historical workouts cannot be in the future.',
      );
    }
    final entries = map['exercises'];
    if (entries != null &&
        (entries is! List || entries.isEmpty || entries.length > 40)) {
      throw const FormatException('Use between 1 and 40 exercises.');
    }
    final seen = <String>{};
    final exercises = entries == null
        ? trusted.exercises
        : [for (final raw in entries as List) _exercise(raw, trusted, seen)];
    return trusted.copyWith(completedAt: date, exercises: exercises);
  }

  static ExerciseLog _exercise(
    Object? raw,
    WorkoutLog trusted,
    Set<String> seen,
  ) {
    final map = object(raw, exerciseFields);
    final id = map['exerciseId'];
    if (id is! String || !seen.add(id)) {
      throw const FormatException(
        'Use unique exercise IDs from the selected workout.',
      );
    }
    final base = trusted.exercises.where((e) => e.exerciseId == id).firstOrNull;
    if (base == null) {
      throw const FormatException(
        'Read the workout first and use one of its exercise IDs.',
      );
    }
    final sets = map['sets'];
    if (sets is! List || sets.isEmpty || sets.length > 50) {
      throw const FormatException('Use between 1 and 50 sets.');
    }
    return base.copyWith(
      sets: [
        for (var i = 0; i < sets.length; i++)
          _set(
            sets[i],
            base.sets[i < base.sets.length ? i : base.sets.length - 1],
          ),
      ],
    );
  }

  static SetLog _set(Object? raw, SetLog base) {
    final map = object(raw, setFields);
    final reps = map['completedReps'] ?? base.completedReps;
    final weight = map['weight'] ?? base.weight;
    final rpe = map.containsKey('completedRpe')
        ? map['completedRpe']
        : base.completedRpe;
    if (reps is! int ||
        reps < 0 ||
        reps > 1000 ||
        weight is! num ||
        !weight.isFinite ||
        weight < 0 ||
        weight > 2000 ||
        (rpe != null &&
            (rpe is! num || !rpe.isFinite || rpe < 0 || rpe > 10))) {
      throw const FormatException('Workout values are out of range.');
    }
    final skipped = map['isSkipped'] as bool? ?? base.isSkipped;
    final completed =
        map['isCompleted'] as bool? ??
        (map.containsKey('completedReps') ? !skipped : base.isCompleted);
    if (skipped && completed) {
      throw const FormatException('A set cannot be completed and skipped.');
    }
    return base.copyWith(
      completedReps: reps,
      weight: weight.toDouble(),
      completedRpe: (rpe as num?)?.toDouble(),
      isSkipped: skipped,
      isCompleted: completed,
    );
  }

  static Map<String, dynamic> editable(WorkoutLog log) => {
    'completedAt': log.completedAt.toIso8601String(),
    'exercises': [
      for (final e in log.exercises)
        {
          'exerciseId': e.exerciseId,
          'sets': [
            for (final s in e.sets)
              {
                'completedReps': s.completedReps,
                'weight': s.weight,
                'completedRpe': s.completedRpe,
                'isCompleted': s.isCompleted,
                'isSkipped': s.isSkipped,
              },
          ],
        },
    ],
  };

  static final schema = <String, dynamic>{
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'completedAt': {
        'type': 'string',
        'description': 'ISO 8601 historical completion time.',
      },
      'exercises': {
        'type': 'array',
        'minItems': 1,
        'maxItems': 40,
        'items': {
          'type': 'object',
          'additionalProperties': false,
          'required': ['exerciseId', 'sets'],
          'properties': {
            'exerciseId': {'type': 'string'},
            'sets': {
              'type': 'array',
              'minItems': 1,
              'maxItems': 50,
              'items': {
                'type': 'object',
                'additionalProperties': false,
                'properties': {
                  'completedReps': {
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 1000,
                  },
                  'weight': {'type': 'number', 'minimum': 0, 'maximum': 2000},
                  'completedRpe': {
                    'type': ['number', 'null'],
                    'minimum': 0,
                    'maximum': 10,
                  },
                  'isCompleted': {'type': 'boolean'},
                  'isSkipped': {'type': 'boolean'},
                },
              },
            },
          },
        },
      },
    },
  };
}
