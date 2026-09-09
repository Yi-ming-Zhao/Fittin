import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/domain/exercise_execution.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('execution schema rejects unknown fields and roundtrips all traits', () {
    const value = ExerciseExecution(
      laterality: ExerciseLaterality.unilateral,
      grip: ExerciseGrip.neutral,
      position: ExercisePosition.incline,
      measurement: ExerciseMeasurement.duration,
      techniques: ['tempo', 'dropSet'],
      equipmentVariant: 'kettlebell',
    );
    expect(ExerciseExecution.fromJson(value.toJson()).toJson(), value.toJson());
    expect(
      () => ExerciseExecution.fromJson({'owner': 'injected'}),
      throwsFormatException,
    );
    expect(
      () => ExerciseExecution.fromJson({
        'techniques': ['anything'],
      }),
      throwsFormatException,
    );
    expect(
      () => ExerciseExecution.fromJson({'equipmentVariant': 'anything'}),
      throwsFormatException,
    );
    expect(
      ExerciseExecution.fromJson({}).measurement,
      ExerciseMeasurement.repetitions,
    );
  });
  test(
    'curated taxonomy separates knee flexion, rotation, and ankle actions',
    () async {
      final library = await ExerciseLibraryLoader().load();
      expect(
        library.findKnown(name: 'Seated Leg Curl')!.movement,
        ExerciseMovement.kneeFlexion,
      );
      expect(library.findKnown(name: 'Wall Tibialis Raise')!.muscles.primary, [
        ExerciseMuscle.tibialisAnterior,
      ]);
      expect(
        library.findKnown(name: 'Forearm Plank')!.execution.measurement,
        ExerciseMeasurement.duration,
      );
      expect(
        library.findKnown(name: 'Barbell Curl 21s')!.execution.techniques,
        containsAll(['twentyOne', 'partial']),
      );
      for (final exercise in library.definitions) {
        expect(
          ExerciseExecution.fromJson(exercise.execution.toJson()).toJson(),
          exercise.execution.toJson(),
        );
      }
    },
  );
}
