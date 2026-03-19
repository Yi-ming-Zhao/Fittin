import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/data/seeds/jacked_and_tan_seed.dart';
import 'package:fittin_v2/src/data/seeds/seed_utils.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';

class InMemoryDatabaseRepository extends DatabaseRepository {
  final Map<String, StoredTemplateRecord> _templates = {};
  final Map<String, StoredTrainingInstance> _instances = {};
  String? _activeInstanceId;
  AppLocale _appLocale = AppLocale.en;
  OneRepMaxFormula _analyticsFormula = OneRepMaxFormula.epley;
  final List<WorkoutLog> _workoutLogs = [];
  String? _deviceId;

  @override
  Future<void> ensureDefaultProgramSeeded() async {
    await saveTemplate(await GzclpSeed.loadTemplate(), isBuiltIn: true);
    await saveTemplate(await JackedAndTanSeed.loadTemplate(), isBuiltIn: true);
  }

  @override
  Future<void> saveTemplate(
    PlanTemplate template, {
    bool isBuiltIn = false,
    String? sourceTemplateId,
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    final existing = _templates[template.id];
    final now = DateTime.now();
    _templates[template.id] = StoredTemplateRecord(
      template: template,
      isBuiltIn: existing?.isBuiltIn ?? isBuiltIn,
      sourceTemplateId: existing?.sourceTemplateId ?? sourceTemplateId,
      createdAt: existing?.createdAt ?? now,
      lastModifiedAt: now,
      instanceCount: existing?.instanceCount ?? 0,
      ownerUserId: existing?.ownerUserId ?? ownerUserId,
      version: (existing?.version ?? 0) + 1,
      syncStatus:
          syncStatus ?? (ownerUserId == null ? 'local_only' : 'pending_upload'),
      lastModifiedByDeviceId: deviceId,
    );
  }

  @override
  Future<PlanTemplate?> fetchTemplate(String templateId) async {
    return _templates[templateId]?.template;
  }

  @override
  Future<StoredTemplateRecord?> fetchStoredTemplate(
    String templateId, {
    String? ownerUserId,
  }) async {
    final record = _templates[templateId];
    if (record == null) {
      return null;
    }
    if (!record.isBuiltIn && record.ownerUserId != ownerUserId) {
      return null;
    }

    return StoredTemplateRecord(
      template: record.template,
      isBuiltIn: record.isBuiltIn,
      sourceTemplateId: record.sourceTemplateId,
      createdAt: record.createdAt,
      lastModifiedAt: record.lastModifiedAt,
      instanceCount: _instances.values
          .where(
            (instance) =>
                instance.templateId == templateId &&
                instance.ownerUserId == ownerUserId,
          )
          .length,
      ownerUserId: record.ownerUserId,
      version: record.version,
      syncStatus: record.syncStatus,
      lastSyncedAt: record.lastSyncedAt,
      lastModifiedByDeviceId: record.lastModifiedByDeviceId,
    );
  }

  @override
  Future<List<StoredTemplateRecord>> fetchTemplates({
    String? ownerUserId,
  }) async {
    final records = await Future.wait(
      _templates.keys.map(
        (key) => fetchStoredTemplate(key, ownerUserId: ownerUserId),
      ),
    );
    final nonNullRecords = records.whereType<StoredTemplateRecord>().toList();
    nonNullRecords.sort((a, b) {
      if (a.isBuiltIn != b.isBuiltIn) {
        return a.isBuiltIn ? -1 : 1;
      }
      return a.template.name.compareTo(b.template.name);
    });
    return nonNullRecords;
  }

  @override
  Future<void> saveInstance(
    StoredTrainingInstance data, {
    String? syncStatus,
    String? deviceId,
  }) async {
    _instances[data.instanceId] = data;
  }

  @override
  Future<StoredTrainingInstance?> fetchInstance(String instanceId) async {
    return _instances[instanceId];
  }

  @override
  Future<String?> fetchActiveInstanceId() async => _activeInstanceId;

  @override
  Future<void> saveActiveInstanceId(String instanceId) async {
    _activeInstanceId = instanceId;
  }

  @override
  Future<AppLocale> fetchAppLocale() async => _appLocale;

  @override
  Future<void> saveAppLocale(AppLocale locale) async {
    _appLocale = locale;
  }

  @override
  Future<OneRepMaxFormula> fetchAnalyticsFormula() async => _analyticsFormula;

  @override
  Future<void> saveAnalyticsFormula(OneRepMaxFormula formula) async {
    _analyticsFormula = formula;
  }

  @override
  Future<String> fetchOrCreateDeviceId() async {
    _deviceId ??= 'test-device-id';
    return _deviceId!;
  }

  @override
  Future<void> claimLocalDataForUser(String ownerUserId) async {
    final updatedTemplates = <String, StoredTemplateRecord>{};
    for (final entry in _templates.entries) {
      final record = entry.value;
      updatedTemplates[entry.key] = StoredTemplateRecord(
        template: record.template,
        isBuiltIn: record.isBuiltIn,
        sourceTemplateId: record.sourceTemplateId,
        createdAt: record.createdAt,
        lastModifiedAt: record.lastModifiedAt,
        instanceCount: record.instanceCount,
        ownerUserId: record.isBuiltIn
            ? null
            : (record.ownerUserId ?? ownerUserId),
        deletedAt: record.deletedAt,
        version: record.version,
        syncStatus: record.isBuiltIn ? record.syncStatus : 'pending_upload',
        lastSyncedAt: record.lastSyncedAt,
        lastModifiedByDeviceId: record.lastModifiedByDeviceId,
      );
    }
    _templates
      ..clear()
      ..addAll(updatedTemplates);

    final updatedInstances = <String, StoredTrainingInstance>{};
    for (final entry in _instances.entries) {
      updatedInstances[entry.key] = entry.value.copyWith(
        ownerUserId: entry.value.ownerUserId ?? ownerUserId,
        syncStatus: 'pending_upload',
      );
    }
    _instances
      ..clear()
      ..addAll(updatedInstances);
  }

  @override
  Future<StoredTrainingInstance?> fetchActiveInstance() async {
    final activeInstanceId = _activeInstanceId;
    if (activeInstanceId == null) {
      return null;
    }
    return _instances[activeInstanceId];
  }

  @override
  Future<StoredTrainingInstance?> fetchInstanceForTemplate(
    String templateId, {
    String? ownerUserId,
  }) async {
    final matches =
        _instances.values
            .where(
              (instance) =>
                  instance.templateId == templateId &&
                  instance.ownerUserId == ownerUserId,
            )
            .toList()
          ..sort((a, b) => a.instanceId.compareTo(b.instanceId));
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<TrainingMaxSetupRequirement?> activationRequirementForTemplate(
    String templateId, {
    String? ownerUserId,
  }) async {
    await ensureDefaultProgramSeeded();
    final existing = await fetchInstanceForTemplate(
      templateId,
      ownerUserId: ownerUserId,
    );
    if (existing != null) {
      return null;
    }

    final template = (await fetchTemplate(templateId))!;
    if (template.requiredTrainingMaxKeys.isEmpty) {
      return null;
    }
    return TrainingMaxSetupRequirement(
      templateId: template.id,
      templateName: template.name,
      liftKeys: template.requiredTrainingMaxKeys,
    );
  }

  @override
  Future<StoredTrainingInstance> activateTemplate(
    String templateId, {
    TrainingMaxProfile trainingMaxProfile = TrainingMaxProfile.empty,
    String? ownerUserId,
  }) async {
    await ensureDefaultProgramSeeded();
    final existing = await fetchInstanceForTemplate(
      templateId,
      ownerUserId: ownerUserId,
    );
    if (existing != null) {
      _activeInstanceId = existing.instanceId;
      return existing;
    }

    final template = (await fetchTemplate(templateId))!;
    if (template.requiredTrainingMaxKeys.isNotEmpty &&
        trainingMaxProfile.isEmpty) {
      throw StateError(
        'Training max setup required before activating ${template.name}.',
      );
    }
    final instanceId = templateId == JackedAndTanSeed.templateId
        ? JackedAndTanSeed.instanceId
        : templateId == GzclpSeed.templateId
        ? GzclpSeed.instanceId
        : 'instance-$templateId';
    final instance = StoredTrainingInstance(
      instanceId: instanceId,
      templateId: templateId,
      currentWorkoutIndex: 0,
      ownerUserId: ownerUserId,
      trainingMaxProfile: trainingMaxProfile,
      engineState: buildInitialEngineState(template),
      states: buildStarterStatesForTemplate(
        template,
        trainingMaxProfile: trainingMaxProfile,
      ),
    );
    await saveInstance(instance);
    _activeInstanceId = instance.instanceId;
    return instance;
  }

  @override
  Future<void> logWorkout(
    WorkoutLog logRecord, {
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    _workoutLogs.add(logRecord);
  }

  @override
  Future<List<WorkoutLog>> fetchWorkoutLogs(
    String instanceId, {
    String? ownerUserId,
  }) async {
    final logs =
        _workoutLogs.where((log) => log.instanceId == instanceId).toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return logs;
  }

  @override
  Future<List<WorkoutLog>> fetchAllWorkoutLogs({String? ownerUserId}) async {
    final logs = [..._workoutLogs]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return logs;
  }
}
