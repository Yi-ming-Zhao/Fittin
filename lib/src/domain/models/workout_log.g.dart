// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutLogImpl _$$WorkoutLogImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutLogImpl(
      logId: json['logId'] as String? ?? '',
      instanceId: json['instanceId'] as String,
      workoutId: json['workoutId'] as String,
      workoutName: json['workoutName'] as String,
      dayLabel: json['dayLabel'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      preConclusionSnapshot: json['preConclusionSnapshot'] == null
          ? null
          : WorkoutProgressionSnapshot.fromJson(
              json['preConclusionSnapshot'] as Map<String, dynamic>),
      postConclusionSnapshot: json['postConclusionSnapshot'] == null
          ? null
          : WorkoutProgressionSnapshot.fromJson(
              json['postConclusionSnapshot'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$WorkoutLogImplToJson(_$WorkoutLogImpl instance) =>
    <String, dynamic>{
      'logId': instance.logId,
      'instanceId': instance.instanceId,
      'workoutId': instance.workoutId,
      'workoutName': instance.workoutName,
      'dayLabel': instance.dayLabel,
      'completedAt': instance.completedAt.toIso8601String(),
      'exercises': instance.exercises,
      'preConclusionSnapshot': instance.preConclusionSnapshot,
      'postConclusionSnapshot': instance.postConclusionSnapshot,
    };

_$WorkoutProgressionSnapshotImpl _$$WorkoutProgressionSnapshotImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkoutProgressionSnapshotImpl(
      templateId: json['templateId'] as String,
      currentWorkoutIndex: (json['currentWorkoutIndex'] as num).toInt(),
      trainingMaxProfile: TrainingMaxProfile.fromJson(
          json['trainingMaxProfile'] as Map<String, dynamic>),
      engineState: json['engineState'] as Map<String, dynamic>,
      states: (json['states'] as List<dynamic>)
          .map((e) => TrainingState.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$WorkoutProgressionSnapshotImplToJson(
        _$WorkoutProgressionSnapshotImpl instance) =>
    <String, dynamic>{
      'templateId': instance.templateId,
      'currentWorkoutIndex': instance.currentWorkoutIndex,
      'trainingMaxProfile': instance.trainingMaxProfile,
      'engineState': instance.engineState,
      'states': instance.states,
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
