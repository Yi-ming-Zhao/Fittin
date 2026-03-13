import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_plan.freezed.dart';
part 'training_plan.g.dart';

@freezed
class PlanTemplate with _$PlanTemplate {
  const factory PlanTemplate({
    required String id,
    required String name,
    required String description,
    @Default(<String, String>{}) Map<String, String> localizedName,
    @Default(<String, String>{}) Map<String, String> localizedDescription,
    @Default('legacy') String engineFamily,
    @Default([]) List<String> requiredTrainingMaxKeys,
    @Default(<String, dynamic>{}) Map<String, dynamic> engineConfig,
    required List<Phase> phases,
  }) = _PlanTemplate;

  factory PlanTemplate.fromJson(Map<String, dynamic> json) =>
      _$PlanTemplateFromJson(json);
}

@freezed
class Phase with _$Phase {
  const factory Phase({
    required String id,
    required String name,
    required List<Workout> workouts,
  }) = _Phase;

  factory Phase.fromJson(Map<String, dynamic> json) => _$PhaseFromJson(json);
}

@freezed
class Workout with _$Workout {
  const factory Workout({
    required String id,
    required String name,
    @Default(<String, String>{}) Map<String, String> localizedName,
    @Default('') String dayLabel,
    @Default(<String, String>{}) Map<String, String> localizedDayLabel,
    @Default(45) int estimatedDurationMinutes,
    required List<Exercise> exercises,
  }) = _Workout;

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);
}

@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String exerciseId, // global ID like 'squat', 'bench_press'
    required String name,
    @Default(<String, String>{}) Map<String, String> localizedName,
    @Default(0) double initialBaseWeight,
    @Default('T2') String tier,
    @Default(120) int restSeconds,
    String? trainingMaxLift,
    @Default(1.0) double trainingMaxMultiplier,
    @Default(2.5) double roundingIncrement,
    @Default(<String, dynamic>{}) Map<String, dynamic> engineConfig,
    required List<SetScheme>
    stages, // Progression stages e.g. Stage 1: 5x3, Stage 2: 6x2
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}

@freezed
class SetScheme with _$SetScheme {
  const factory SetScheme({
    required String id,
    required String name,
    @Default(1.0) double basePercent,
    @Default(0) int order,
    @Default(<String, dynamic>{}) Map<String, dynamic> engineConfig,
    required List<SetDefinition> sets,
    required List<ProgressionRule> rules,
  }) = _SetScheme;

  factory SetScheme.fromJson(Map<String, dynamic> json) =>
      _$SetSchemeFromJson(json);
}

@freezed
class SetDefinition with _$SetDefinition {
  const factory SetDefinition({
    required int targetReps,
    required double intensity, // multiplier of TM or base weight e.g. 0.85
    @Default(false) bool isAmrap,
    @Default('working') String kind,
  }) = _SetDefinition;

  factory SetDefinition.fromJson(Map<String, dynamic> json) =>
      _$SetDefinitionFromJson(json);
}

@freezed
class ProgressionRule with _$ProgressionRule {
  const factory ProgressionRule({
    required String condition, // e.g. '${failed_sets} == 0'
    required List<RuleAction> actions,
  }) = _ProgressionRule;

  factory ProgressionRule.fromJson(Map<String, dynamic> json) =>
      _$ProgressionRuleFromJson(json);
}

@freezed
class RuleAction with _$RuleAction {
  const factory RuleAction({
    required String
    type, // 'ADD_WEIGHT', 'JUMP_TO_STAGE', 'STAY_STAGE', 'MULTIPLY_WEIGHT'
    double? amount, // amount to add
    double? multiplier, // multiplier
    String? targetStageId, // target scheme id
  }) = _RuleAction;

  factory RuleAction.fromJson(Map<String, dynamic> json) =>
      _$RuleActionFromJson(json);
}

extension PlanTemplateLookup on PlanTemplate {
  List<Workout> get workouts => [for (final phase in phases) ...phase.workouts];

  Workout workoutByIndex(int index) {
    final allWorkouts = workouts;
    if (allWorkouts.isEmpty) {
      throw StateError('PlanTemplate does not contain any workouts.');
    }
    return allWorkouts[index % allWorkouts.length];
  }

  Workout findWorkoutById(String workoutId) {
    return workouts.firstWhere(
      (workout) => workout.id == workoutId,
      orElse: () => throw StateError('Workout not found: $workoutId'),
    );
  }

  Exercise findExerciseById(String exerciseId) {
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        if (exercise.id == exerciseId) {
          return exercise;
        }
      }
    }
    throw StateError('Exercise not found: $exerciseId');
  }
}

extension LocalizedPlanTemplateLookup on PlanTemplate {
  String displayName(String localeCode) =>
      localizedName[localeCode] ?? name;

  String displayDescription(String localeCode) =>
      localizedDescription[localeCode] ?? description;
}

extension LocalizedWorkoutLookup on Workout {
  String displayName(String localeCode) =>
      localizedName[localeCode] ?? name;

  String displayDayLabel(String localeCode) =>
      localizedDayLabel[localeCode] ?? dayLabel;
}

extension LocalizedExerciseLookup on Exercise {
  String displayName(String localeCode) =>
      localizedName[localeCode] ?? name;
}

extension ExerciseLookup on Exercise {
  SetScheme stageById(String stageId) {
    return stages.firstWhere(
      (stage) => stage.id == stageId,
      orElse: () => stages.first,
    );
  }
}
