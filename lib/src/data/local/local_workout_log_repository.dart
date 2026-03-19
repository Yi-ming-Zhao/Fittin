import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';

final localWorkoutLogRepositoryProvider = Provider<LocalWorkoutLogRepository>((
  ref,
) {
  return LocalWorkoutLogRepository(
    repository: ref.watch(databaseRepositoryProvider),
    ownerUserId: ref.watch(currentUserIdProvider),
  );
});

class LocalWorkoutLogRepository {
  LocalWorkoutLogRepository({
    required DatabaseRepository repository,
    required String? ownerUserId,
  }) : _repository = repository,
       _ownerUserId = ownerUserId;

  final DatabaseRepository _repository;
  final String? _ownerUserId;

  Future<void> logWorkout(WorkoutLog log) {
    return _repository.logWorkout(log, ownerUserId: _ownerUserId);
  }

  Future<List<WorkoutLog>> fetchWorkoutLogs(String instanceId) {
    return _repository.fetchWorkoutLogs(instanceId, ownerUserId: _ownerUserId);
  }

  Future<List<WorkoutLog>> fetchAllWorkoutLogs() {
    return _repository.fetchAllWorkoutLogs(ownerUserId: _ownerUserId);
  }
}
