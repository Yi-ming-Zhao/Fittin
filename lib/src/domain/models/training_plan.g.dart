// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanTemplateImpl _$$PlanTemplateImplFromJson(Map<String, dynamic> json) =>
    _$PlanTemplateImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      localizedName: (json['localizedName'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      localizedDescription:
          (json['localizedDescription'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              ) ??
              const <String, String>{},
      engineFamily: json['engineFamily'] as String? ?? 'legacy',
      requiredTrainingMaxKeys:
          (json['requiredTrainingMaxKeys'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      engineConfig: json['engineConfig'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      phases: (json['phases'] as List<dynamic>)
          .map((e) => Phase.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PlanTemplateImplToJson(_$PlanTemplateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'localizedName': instance.localizedName,
      'localizedDescription': instance.localizedDescription,
      'engineFamily': instance.engineFamily,
      'requiredTrainingMaxKeys': instance.requiredTrainingMaxKeys,
      'engineConfig': instance.engineConfig,
      'phases': instance.phases,
    };

_$PhaseImpl _$$PhaseImplFromJson(Map<String, dynamic> json) => _$PhaseImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      workouts: (json['workouts'] as List<dynamic>)
          .map((e) => Workout.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PhaseImplToJson(_$PhaseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'workouts': instance.workouts,
    };

_$WorkoutImpl _$$WorkoutImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      localizedName: (json['localizedName'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      dayLabel: json['dayLabel'] as String? ?? '',
      localizedDayLabel:
          (json['localizedDayLabel'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              ) ??
              const <String, String>{},
      estimatedDurationMinutes:
          (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 45,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$WorkoutImplToJson(_$WorkoutImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'localizedName': instance.localizedName,
      'dayLabel': instance.dayLabel,
      'localizedDayLabel': instance.localizedDayLabel,
      'estimatedDurationMinutes': instance.estimatedDurationMinutes,
      'exercises': instance.exercises,
    };

_$ExerciseImpl _$$ExerciseImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseImpl(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      localizedName: (json['localizedName'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      initialBaseWeight: (json['initialBaseWeight'] as num?)?.toDouble() ?? 0,
      tier: json['tier'] as String? ?? 'T2',
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 120,
      trainingMaxLift: json['trainingMaxLift'] as String?,
      trainingMaxMultiplier:
          (json['trainingMaxMultiplier'] as num?)?.toDouble() ?? 1.0,
      roundingIncrement: (json['roundingIncrement'] as num?)?.toDouble() ?? 2.5,
      engineConfig: json['engineConfig'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      stages: (json['stages'] as List<dynamic>)
          .map((e) => SetScheme.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ExerciseImplToJson(_$ExerciseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'name': instance.name,
      'localizedName': instance.localizedName,
      'initialBaseWeight': instance.initialBaseWeight,
      'tier': instance.tier,
      'restSeconds': instance.restSeconds,
      'trainingMaxLift': instance.trainingMaxLift,
      'trainingMaxMultiplier': instance.trainingMaxMultiplier,
      'roundingIncrement': instance.roundingIncrement,
      'engineConfig': instance.engineConfig,
      'stages': instance.stages,
    };

_$SetSchemeImpl _$$SetSchemeImplFromJson(Map<String, dynamic> json) =>
    _$SetSchemeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      basePercent: (json['basePercent'] as num?)?.toDouble() ?? 1.0,
      order: (json['order'] as num?)?.toInt() ?? 0,
      engineConfig: json['engineConfig'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      sets: (json['sets'] as List<dynamic>)
          .map((e) => SetDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      rules: (json['rules'] as List<dynamic>)
          .map((e) => ProgressionRule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SetSchemeImplToJson(_$SetSchemeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'basePercent': instance.basePercent,
      'order': instance.order,
      'engineConfig': instance.engineConfig,
      'sets': instance.sets,
      'rules': instance.rules,
    };

_$SetDefinitionImpl _$$SetDefinitionImplFromJson(Map<String, dynamic> json) =>
    _$SetDefinitionImpl(
      targetReps: (json['targetReps'] as num).toInt(),
      intensity: (json['intensity'] as num).toDouble(),
      isAmrap: json['isAmrap'] as bool? ?? false,
      kind: json['kind'] as String? ?? 'working',
    );

Map<String, dynamic> _$$SetDefinitionImplToJson(_$SetDefinitionImpl instance) =>
    <String, dynamic>{
      'targetReps': instance.targetReps,
      'intensity': instance.intensity,
      'isAmrap': instance.isAmrap,
      'kind': instance.kind,
    };

_$ProgressionRuleImpl _$$ProgressionRuleImplFromJson(
        Map<String, dynamic> json) =>
    _$ProgressionRuleImpl(
      condition: json['condition'] as String,
      actions: (json['actions'] as List<dynamic>)
          .map((e) => RuleAction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ProgressionRuleImplToJson(
        _$ProgressionRuleImpl instance) =>
    <String, dynamic>{
      'condition': instance.condition,
      'actions': instance.actions,
    };

_$RuleActionImpl _$$RuleActionImplFromJson(Map<String, dynamic> json) =>
    _$RuleActionImpl(
      type: json['type'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      multiplier: (json['multiplier'] as num?)?.toDouble(),
      targetStageId: json['targetStageId'] as String?,
    );

Map<String, dynamic> _$$RuleActionImplToJson(_$RuleActionImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'amount': instance.amount,
      'multiplier': instance.multiplier,
      'targetStageId': instance.targetStageId,
    };
