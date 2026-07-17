import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseLog exercise identity', () {
    test('legacy JSON without a canonical definition ID remains readable', () {
      final log = ExerciseLog.fromJson({
        'exerciseId': 'day1-bench',
        'exerciseName': 'Bench Press',
        'stageId': 'stage-1',
        'displayLoadUnit': 'kg',
        'sets': <Map<String, Object?>>[],
      });

      expect(log.exerciseId, 'day1-bench');
      expect(log.exerciseDefinitionId, isEmpty);
    });

    test('new JSON preserves occurrence and canonical identities', () {
      const log = ExerciseLog(
        exerciseId: 'day1-bench',
        exerciseDefinitionId: 'bench_press',
        exerciseName: 'Bench Press',
        stageId: 'stage-1',
        sets: [],
      );

      final restored = ExerciseLog.fromJson(log.toJson());

      expect(restored.exerciseId, 'day1-bench');
      expect(restored.exerciseDefinitionId, 'bench_press');
    });
  });

  group('SetLog skipped state', () {
    test('legacy JSON defaults skipped state to false', () {
      final set = SetLog.fromJson({
        'role': 'work',
        'targetReps': 5,
        'completedReps': 0,
        'targetWeight': 100.0,
        'weight': 100.0,
      });

      expect(set.isSkipped, isFalse);
    });

    test('new JSON preserves skipped state', () {
      const set = SetLog(
        role: 'work',
        targetReps: 5,
        completedReps: 0,
        targetWeight: 100,
        weight: 100,
        isSkipped: true,
      );

      expect(SetLog.fromJson(set.toJson()).isSkipped, isTrue);
    });
  });
}
