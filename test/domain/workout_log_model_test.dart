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
}
