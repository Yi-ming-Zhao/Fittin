// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutLogImpl _$$WorkoutLogImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutLogImpl(
      instanceId: json['instanceId'] as String,
      workoutId: json['workoutId'] as String,
      workoutName: json['workoutName'] as String,
      dayLabel: json['dayLabel'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$WorkoutLogImplToJson(_$WorkoutLogImpl instance) =>
    <String, dynamic>{
      'instanceId': instance.instanceId,
      'workoutId': instance.workoutId,
      'workoutName': instance.workoutName,
      'dayLabel': instance.dayLabel,
      'completedAt': instance.completedAt.toIso8601String(),
      'exercises': instance.exercises,
    };

_$ExerciseLogImpl _$$ExerciseLogImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseLogImpl(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      stageId: json['stageId'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((e) => SetLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ExerciseLogImplToJson(_$ExerciseLogImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'stageId': instance.stageId,
      'sets': instance.sets,
    };

_$SetLogImpl _$$SetLogImplFromJson(Map<String, dynamic> json) => _$SetLogImpl(
      role: json['role'] as String,
      targetReps: (json['targetReps'] as num).toInt(),
      completedReps: (json['completedReps'] as num).toInt(),
      targetWeight: (json['targetWeight'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      isAmrap: json['isAmrap'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$SetLogImplToJson(_$SetLogImpl instance) =>
    <String, dynamic>{
      'role': instance.role,
      'targetReps': instance.targetReps,
      'completedReps': instance.completedReps,
      'targetWeight': instance.targetWeight,
      'weight': instance.weight,
      'isAmrap': instance.isAmrap,
      'isCompleted': instance.isCompleted,
    };
