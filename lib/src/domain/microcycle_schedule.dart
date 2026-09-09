import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';

const microcycleOrderEngineKey = 'microcycleOrder';
const microcycleGenerationEngineKey = 'microcycleGeneration';
const releasedWorkoutQueueEngineKey = 'releasedWorkoutQueue';

List<String> releasedWorkoutQueue(StoredTrainingInstance instance) =>
    (instance.engineState[releasedWorkoutQueueEngineKey] as List? ?? const [])
        .whereType<String>()
        .toList();

StoredTrainingInstance skipScheduledWorkout({
  required PlanTemplate template,
  required StoredTrainingInstance instance,
}) {
  final queue = releasedWorkoutQueue(instance);
  if (queue.isNotEmpty) {
    return instance.copyWith(
      engineState: {
        ...instance.engineState,
        releasedWorkoutQueueEngineKey: queue.skip(1).toList(),
      },
    );
  }
  final nextIndex =
      (instance.currentWorkoutIndex + 1) % template.workouts.length;
  var engineState = {...instance.engineState};
  if (nextIndex == 0 && template.engineFamily == 'periodized_tm') {
    final nextWeek =
        ((engineState['currentWeekIndex'] as num?)?.toInt() ?? 0) + 1;
    final weeks =
        ((engineState['cycleLengthWeeks'] as num?)?.toInt() ??
                template.workouts.first.exercises.first.stages.length)
            .clamp(1, 10000);
    engineState.addAll({
      'currentWeekIndex': nextWeek,
      'currentBlockIndex': nextWeek ~/ weeks,
    });
  }
  return instance.copyWith(
    currentWorkoutIndex: nextIndex,
    states: template.engineFamily == 'periodized_tm'
        ? instance.states.map((state) {
            final skippedId = resolveMicrocycleSchedule(
              template: template,
              instance: instance,
            ).currentWorkoutId;
            if (state.workoutId != skippedId) return state;
            final exercise = template.findExerciseById(state.exerciseId);
            final index = exercise.stages.indexWhere(
              (stage) => stage.id == state.currentStageId,
            );
            if (index < 0 || index + 1 >= exercise.stages.length) return state;
            return state.copyWith(
              currentStageId: exercise.stages[index + 1].id,
            );
          }).toList()
        : instance.states,
    engineState: normalizeMicrocycleAfterAdvance(
      template: template,
      nextWorkoutIndex: nextIndex,
      engineState: engineState,
    ),
  );
}

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
