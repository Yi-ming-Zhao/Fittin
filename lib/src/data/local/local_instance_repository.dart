import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/plan_start_load_review.dart';

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

  Future<StoredTrainingInstance?> fetchInstance(String instanceId) async {
    final instance = await _repository.fetchInstance(instanceId);
    return instance?.ownerUserId == _ownerUserId ? instance : null;
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
    PlanStartLoadReview? planStartLoadReview,
  }) async {
    final existing = await fetchInstanceForTemplate(templateId);
    if (existing != null && existing.engineState['lifecycle'] == 'stopped') {
      return transition(
        existing,
        action: InstanceLifecycleAction.resume,
        expectedActiveInstanceId: await fetchActiveInstanceId(),
      );
    }
    return _repository.activateTemplate(
      templateId,
      trainingMaxProfile: trainingMaxProfile,
      planStartLoadReview: planStartLoadReview,
      ownerUserId: _ownerUserId,
    );
  }

  Future<StoredTrainingInstance> transition(
    StoredTrainingInstance expected, {
    required InstanceLifecycleAction action,
    required String? expectedActiveInstanceId,
    TrainingMaxProfile trainingMaxProfile = TrainingMaxProfile.empty,
    PlanStartLoadReview? planStartLoadReview,
    bool discardDraft = false,
  }) => _repository.transitionInstance(
    expected: expected,
    ownerUserId: _ownerUserId,
    expectedActiveInstanceId: expectedActiveInstanceId,
    action: action,
    trainingMaxProfile: trainingMaxProfile,
    planStartLoadReview: planStartLoadReview,
    discardDraft: discardDraft,
  );

  Future<void> saveInstance(StoredTrainingInstance instance) {
    return _repository.saveInstance(instance);
  }

  Future<void> saveAndActivateInstance(StoredTrainingInstance instance) async {
    if (instance.ownerUserId != _ownerUserId) {
      throw StateError('The training instance belongs to another user.');
    }
    await _repository.saveInstance(instance);
    await _repository.saveActiveInstanceIdForUser(
      instance.instanceId,
      _ownerUserId,
    );
  }

  Future<void> activateStoredInstance(String instanceId) async {
    final instance = await _repository.fetchInstance(instanceId);
    if (instance == null || instance.ownerUserId != _ownerUserId) {
      throw StateError('The training instance is no longer available.');
    }
    if (instance.engineState['lifecycle'] == 'stopped') {
      await transition(
        instance,
        action: InstanceLifecycleAction.resume,
        expectedActiveInstanceId: await fetchActiveInstanceId(),
      );
      return;
    }
    await _repository.saveActiveInstanceIdForUser(instanceId, _ownerUserId);
  }

  Future<void> deleteInstance(String instanceId) {
    return _repository.deleteInstance(instanceId, ownerUserId: _ownerUserId);
  }
}
