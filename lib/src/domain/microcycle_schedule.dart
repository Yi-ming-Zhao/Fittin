import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';

const microcycleOrderEngineKey = 'microcycleOrder';
const microcycleGenerationEngineKey = 'microcycleGeneration';

class MicrocycleSchedule {
  const MicrocycleSchedule({
    required this.cycleGeneration,
    required this.positionInCycle,
    required this.orderedWorkoutIds,
  });

  final int cycleGeneration;
  final int positionInCycle;
  final List<String> orderedWorkoutIds;

  String get currentWorkoutId => orderedWorkoutIds[positionInCycle];

  List<String> get remainingWorkoutIds =>
      orderedWorkoutIds.skip(positionInCycle).toList(growable: false);

  Map<String, dynamic> toJson() => {
    'cycleGeneration': cycleGeneration,
    'positionInCycle': positionInCycle,
    'orderedWorkoutIds': orderedWorkoutIds,
  };
}

MicrocycleSchedule resolveMicrocycleSchedule({
  required PlanTemplate template,
  required StoredTrainingInstance instance,
}) {
  final canonical = template.workouts.map((workout) => workout.id).toList();
  if (canonical.isEmpty) {
    throw StateError('PlanTemplate does not contain any workouts.');
  }
  final position = instance.currentWorkoutIndex % canonical.length;
  final generation =
      (instance.engineState[microcycleGenerationEngineKey] as num?)?.toInt() ??
      0;
  final raw = instance.engineState[microcycleOrderEngineKey];
  if (raw is Map) {
    final value = raw.cast<String, dynamic>();
    final storedOrder = (value['orderedWorkoutIds'] as List? ?? const [])
        .whereType<String>()
        .toList(growable: false);
    final storedGeneration = value['cycleGeneration'] as int?;
    if (storedGeneration == generation &&
        storedOrder.length == canonical.length &&
        storedOrder.toSet().length == canonical.length &&
        storedOrder.toSet().containsAll(canonical)) {
      return MicrocycleSchedule(
        cycleGeneration: generation,
        positionInCycle: position,
        orderedWorkoutIds: storedOrder,
      );
    }
  }
  return MicrocycleSchedule(
    cycleGeneration: generation,
    positionInCycle: position,
    orderedWorkoutIds: canonical,
  );
}

Map<String, dynamic> reorderMicrocycleEngineState({
  required PlanTemplate template,
  required StoredTrainingInstance instance,
  required String nextWorkoutId,
}) {
  final schedule = resolveMicrocycleSchedule(
    template: template,
    instance: instance,
  );
  final remaining = [...schedule.remainingWorkoutIds];
  final selectedIndex = remaining.indexOf(nextWorkoutId);
  if (selectedIndex < 0) {
    throw StateError('Only a remaining workout can be moved to today.');
  }
  remaining
    ..removeAt(selectedIndex)
    ..insert(0, nextWorkoutId);
  final prefix = schedule.orderedWorkoutIds
      .take(schedule.positionInCycle)
      .toList(growable: false);
  return {
    ...instance.engineState,
    microcycleOrderEngineKey: MicrocycleSchedule(
      cycleGeneration: schedule.cycleGeneration,
      positionInCycle: schedule.positionInCycle,
      orderedWorkoutIds: [...prefix, ...remaining],
    ).toJson(),
  };
}

Map<String, dynamic> normalizeMicrocycleAfterAdvance({
  required PlanTemplate template,
  required int nextWorkoutIndex,
  required Map<String, dynamic> engineState,
}) {
  if (template.workouts.isEmpty ||
      nextWorkoutIndex % template.workouts.length != 0) {
    return engineState;
  }
  final generation =
      (engineState[microcycleGenerationEngineKey] as num?)?.toInt() ?? 0;
  return Map<String, dynamic>.from(engineState)
    ..remove(microcycleOrderEngineKey)
    ..[microcycleGenerationEngineKey] = generation + 1;
}
