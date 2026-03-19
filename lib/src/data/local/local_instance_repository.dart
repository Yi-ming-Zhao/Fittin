import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';

final localInstanceRepositoryProvider = Provider<LocalInstanceRepository>((
  ref,
) {
  return LocalInstanceRepository(
    repository: ref.watch(databaseRepositoryProvider),
    ownerUserId: ref.watch(currentUserIdProvider),
  );
});

class LocalInstanceRepository {
  LocalInstanceRepository({
    required DatabaseRepository repository,
    required String? ownerUserId,
  }) : _repository = repository,
       _ownerUserId = ownerUserId;

  final DatabaseRepository _repository;
  final String? _ownerUserId;

  Future<String?> fetchActiveInstanceId() {
    return _repository.fetchActiveInstanceIdForUser(_ownerUserId);
  }

  Future<StoredTrainingInstance?> fetchActiveInstance() {
    return _repository.fetchActiveInstanceForUser(_ownerUserId);
  }

  Future<StoredTrainingInstance?> fetchInstanceForTemplate(String templateId) {
    return _repository.fetchInstanceForTemplate(
      templateId,
      ownerUserId: _ownerUserId,
    );
  }

  Future<TrainingMaxSetupRequirement?> activationRequirementForTemplate(
    String templateId,
  ) {
    return _repository.activationRequirementForTemplate(
      templateId,
      ownerUserId: _ownerUserId,
    );
  }

  Future<StoredTrainingInstance> activateTemplate(
    String templateId, {
    TrainingMaxProfile trainingMaxProfile = TrainingMaxProfile.empty,
  }) {
    return _repository.activateTemplate(
      templateId,
      trainingMaxProfile: trainingMaxProfile,
      ownerUserId: _ownerUserId,
    );
  }

  Future<void> saveInstance(StoredTrainingInstance instance) {
    return _repository.saveInstance(instance);
  }
}
