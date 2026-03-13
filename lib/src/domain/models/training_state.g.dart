// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingStateImpl _$$TrainingStateImplFromJson(Map<String, dynamic> json) =>
    _$TrainingStateImpl(
      workoutId: json['workoutId'] as String,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      baseWeight: (json['baseWeight'] as num).toDouble(),
      currentStageId: json['currentStageId'] as String,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TrainingStateImplToJson(_$TrainingStateImpl instance) =>
    <String, dynamic>{
      'workoutId': instance.workoutId,
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'baseWeight': instance.baseWeight,
      'currentStageId': instance.currentStageId,
      'history': instance.history,
    };

_$SessionSetStateImpl _$$SessionSetStateImplFromJson(
        Map<String, dynamic> json) =>
    _$SessionSetStateImpl(
      id: json['id'] as String,
      role: json['role'] as String,
      targetReps: (json['targetReps'] as num).toInt(),
      completedReps: (json['completedReps'] as num).toInt(),
      targetWeight: (json['targetWeight'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      isAmrap: json['isAmrap'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$SessionSetStateImplToJson(
        _$SessionSetStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'targetReps': instance.targetReps,
      'completedReps': instance.completedReps,
      'targetWeight': instance.targetWeight,
      'weight': instance.weight,
      'isAmrap': instance.isAmrap,
      'isCompleted': instance.isCompleted,
    };

_$ExerciseSessionStateImpl _$$ExerciseSessionStateImplFromJson(
        Map<String, dynamic> json) =>
    _$ExerciseSessionStateImpl(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      tier: json['tier'] as String,
      restSeconds: (json['restSeconds'] as num).toInt(),
      stageId: json['stageId'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((e) => SessionSetState.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ExerciseSessionStateImplToJson(
        _$ExerciseSessionStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'tier': instance.tier,
      'restSeconds': instance.restSeconds,
      'stageId': instance.stageId,
      'sets': instance.sets,
    };

_$WorkoutSessionStateImpl _$$WorkoutSessionStateImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkoutSessionStateImpl(
      instanceId: json['instanceId'] as String,
      templateId: json['templateId'] as String,
      workoutId: json['workoutId'] as String,
      workoutName: json['workoutName'] as String,
      dayLabel: json['dayLabel'] as String,
      estimatedDurationMinutes:
          (json['estimatedDurationMinutes'] as num).toInt(),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseSessionState.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentExerciseIndex:
          (json['currentExerciseIndex'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$WorkoutSessionStateImplToJson(
        _$WorkoutSessionStateImpl instance) =>
    <String, dynamic>{
      'instanceId': instance.instanceId,
      'templateId': instance.templateId,
      'workoutId': instance.workoutId,
      'workoutName': instance.workoutName,
      'dayLabel': instance.dayLabel,
      'estimatedDurationMinutes': instance.estimatedDurationMinutes,
      'exercises': instance.exercises,
      'currentExerciseIndex': instance.currentExerciseIndex,
    };

_$TodayWorkoutSummaryImpl _$$TodayWorkoutSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$TodayWorkoutSummaryImpl(
      instanceId: json['instanceId'] as String,
      workoutId: json['workoutId'] as String,
      workoutName: json['workoutName'] as String,
      dayLabel: json['dayLabel'] as String,
      primaryExerciseId: json['primaryExerciseId'] as String,
      primaryExerciseName: json['primaryExerciseName'] as String,
      estimatedDurationMinutes:
          (json['estimatedDurationMinutes'] as num).toInt(),
      exerciseCount: (json['exerciseCount'] as num).toInt(),
    );

Map<String, dynamic> _$$TodayWorkoutSummaryImplToJson(
        _$TodayWorkoutSummaryImpl instance) =>
    <String, dynamic>{
      'instanceId': instance.instanceId,
      'workoutId': instance.workoutId,
      'workoutName': instance.workoutName,
      'dayLabel': instance.dayLabel,
      'primaryExerciseId': instance.primaryExerciseId,
      'primaryExerciseName': instance.primaryExerciseName,
      'estimatedDurationMinutes': instance.estimatedDurationMinutes,
      'exerciseCount': instance.exerciseCount,
    };
