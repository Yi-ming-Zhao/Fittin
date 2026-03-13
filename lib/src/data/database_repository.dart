import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:fittin_v2/src/data/models/app_state_collection.dart';
import 'package:fittin_v2/src/data/models/template_collection.dart';
import 'package:fittin_v2/src/data/models/instance_collection.dart';
import 'package:fittin_v2/src/data/models/workout_log_collection.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/data/seeds/jacked_and_tan_seed.dart';
import 'package:fittin_v2/src/data/seeds/seed_utils.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';

class DatabaseRepository {
  static const _activeStateKey = 'active-instance-selection';
  static const _localeStateKey = 'app-locale';
  static const _analyticsFormulaStateKey = 'analytics-formula';
  final Isar? _isar;

  DatabaseRepository([this._isar]);

  Isar get _database {
    final isar = _isar;
    if (isar == null) {
      throw StateError('This repository instance is not backed by Isar.');
    }
    return isar;
  }

  Future<void> ensureDefaultProgramSeeded() async {
    await _syncBuiltInTemplate(
      templateId: GzclpSeed.templateId,
      loadTemplate: GzclpSeed.loadTemplate,
    );
    await _syncBuiltInTemplate(
      templateId: JackedAndTanSeed.templateId,
      loadTemplate: JackedAndTanSeed.loadTemplate,
    );
    await _purgeLegacyBuiltInInstanceIfNeeded(GzclpSeed.instanceId);
    await _purgeLegacyBuiltInInstanceIfNeeded(JackedAndTanSeed.instanceId);

    final activeInstanceId = await fetchActiveInstanceId();
    final activeInstance = activeInstanceId == null
        ? null
        : await fetchInstance(activeInstanceId);
    if (activeInstanceId != null && activeInstance == null) {
      await clearActiveInstanceId();
    }
  }

  // ---------- Templates ---------- //

  Future<void> saveTemplate(
    PlanTemplate template, {
    bool isBuiltIn = false,
    String? sourceTemplateId,
  }) async {
    final Map<String, dynamic> templateJson = template.toJson();
    final String serialized = jsonEncode(templateJson);
    final existing = await _database.templateCollections.getByTemplateId(
      template.id,
    );

    final collection = TemplateCollection()
      ..templateId = template.id
      ..name = template.name
      ..description = template.description
      ..isBuiltIn = existing?.isBuiltIn ?? isBuiltIn
      ..sourceTemplateId = existing?.sourceTemplateId ?? sourceTemplateId
      ..createdAt = existing?.createdAt ?? DateTime.now()
      ..lastModifiedAt = DateTime.now()
      ..rawJsonPayload = serialized;

    await _database.writeTxn(() async {
      await _database.templateCollections.putByTemplateId(collection);
    });
  }

  Future<PlanTemplate?> fetchTemplate(String templateId) async {
    final collection = await _database.templateCollections.getByTemplateId(
      templateId,
    );
    if (collection == null) return null;
    return PlanTemplate.fromJson(jsonDecode(collection.rawJsonPayload));
  }

  Future<StoredTemplateRecord?> fetchStoredTemplate(String templateId) async {
    final collection = await _database.templateCollections.getByTemplateId(
      templateId,
    );
    if (collection == null) {
      return null;
    }
    final instanceCount = await _instanceCountForTemplate(templateId);
    return _toStoredTemplateRecord(collection, instanceCount);
  }

  Future<List<StoredTemplateRecord>> fetchTemplates() async {
    final collections = await _database.templateCollections.where().findAll();
    final instances = await _database.instanceCollections.where().findAll();
    final counts = <String, int>{};
    for (final instance in instances) {
      counts.update(
        instance.templateId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    final records = collections
        .map(
          (collection) => _toStoredTemplateRecord(
            collection,
            counts[collection.templateId] ?? 0,
          ),
        )
        .toList();

    records.sort((a, b) {
      if (a.isBuiltIn != b.isBuiltIn) {
        return a.isBuiltIn ? -1 : 1;
      }
      return a.template.name.toLowerCase().compareTo(
        b.template.name.toLowerCase(),
      );
    });
    return records;
  }

  Future<PlanTemplate?> fetchTemplateForInstance(String instanceId) async {
    final instance = await fetchInstance(instanceId);
    if (instance == null) {
      return null;
    }
    return fetchTemplate(instance.templateId);
  }

  Future<PlanTemplate> importSharedTemplate(PlanTemplate template) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final importedTemplate = template.copyWith(
      id: '${_slugifyTemplateId(template.id)}-imported-$timestamp',
      name: '${template.name} (Imported)',
      description: '${template.description}\nImported via QR sharing.',
    );
    await saveTemplate(importedTemplate, sourceTemplateId: template.id);
    return importedTemplate;
  }

  Future<StoredTemplateRecord> saveEditedTemplate({
    required PlanTemplate draft,
    String? originalTemplateId,
  }) async {
    final existing = originalTemplateId == null
        ? null
        : await fetchStoredTemplate(originalTemplateId);
    final shouldFork =
        existing == null || existing.isBuiltIn || existing.instanceCount > 0;

    final templateToSave = shouldFork
        ? draft.copyWith(
            id: _generatedTemplateId(
              draft.name,
              fallbackSourceId: existing?.template.id ?? draft.id,
            ),
          )
        : draft.copyWith(id: existing.template.id);

    final sourceTemplateId =
        existing?.sourceTemplateId ?? existing?.template.id;

    await saveTemplate(
      templateToSave,
      isBuiltIn: false,
      sourceTemplateId: sourceTemplateId,
    );

    return (await fetchStoredTemplate(templateToSave.id))!;
  }

  Future<String?> fetchActiveInstanceId() async {
    final state = await _database.appStateCollections.getByStateKey(
      _activeStateKey,
    );
    return state?.activeInstanceId;
  }

  Future<void> saveActiveInstanceId(String instanceId) async {
    final existing = await _database.appStateCollections.getByStateKey(
      _activeStateKey,
    );
    final state = AppStateCollection()
      ..stateKey = _activeStateKey
      ..activeInstanceId = instanceId
      ..updatedAt = DateTime.now();
    if (existing != null) {
      state.id = existing.id;
    }

    await _database.writeTxn(() async {
      await _database.appStateCollections.putByStateKey(state);
    });
  }

  Future<void> clearActiveInstanceId() async {
    final existing = await _database.appStateCollections.getByStateKey(
      _activeStateKey,
    );
    if (existing == null) {
      return;
    }

    final state = AppStateCollection()
      ..id = existing.id
      ..stateKey = _activeStateKey
      ..updatedAt = DateTime.now();

    await _database.writeTxn(() async {
      await _database.appStateCollections.putByStateKey(state);
    });
  }

  Future<AppLocale> fetchAppLocale() async {
    final state = await _database.appStateCollections.getByStateKey(
      _localeStateKey,
    );
    return AppLocaleX.fromCode(state?.localeCode);
  }

  Future<void> saveAppLocale(AppLocale locale) async {
    final existing = await _database.appStateCollections.getByStateKey(
      _localeStateKey,
    );
    final state = AppStateCollection()
      ..stateKey = _localeStateKey
      ..localeCode = locale.code
      ..updatedAt = DateTime.now();
    if (existing != null) {
      state.id = existing.id;
      state.activeInstanceId = existing.activeInstanceId;
    }

    await _database.writeTxn(() async {
      await _database.appStateCollections.putByStateKey(state);
    });
  }

  Future<OneRepMaxFormula> fetchAnalyticsFormula() async {
    final state = await _database.appStateCollections.getByStateKey(
      _analyticsFormulaStateKey,
    );
    return OneRepMaxFormulaX.fromKey(state?.analyticsFormulaKey);
  }

  Future<void> saveAnalyticsFormula(OneRepMaxFormula formula) async {
    final existing = await _database.appStateCollections.getByStateKey(
      _analyticsFormulaStateKey,
    );
    final state = existing ?? AppStateCollection();
    state.stateKey = _analyticsFormulaStateKey;
    state.analyticsFormulaKey = formula.key;
    state.updatedAt = DateTime.now();

    await _database.writeTxn(() async {
      await _database.appStateCollections.putByStateKey(state);
    });
  }

  Future<StoredTrainingInstance?> fetchActiveInstance() async {
    final activeInstanceId = await fetchActiveInstanceId();
    if (activeInstanceId == null) {
      return null;
    }
    return fetchInstance(activeInstanceId);
  }

  Future<StoredTrainingInstance?> fetchInstanceForTemplate(
    String templateId,
  ) async {
    final collections = await _database.instanceCollections
        .filter()
        .templateIdEqualTo(templateId)
        .findAll();
    if (collections.isEmpty) {
      return null;
    }

    collections.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final collection = collections.first;
    return StoredTrainingInstance(
      instanceId: collection.instanceId,
      templateId: collection.templateId,
      currentWorkoutIndex: collection.currentWorkoutIndex,
      trainingMaxProfile:
          collection.trainingMaxProfileJson == null
          ? TrainingMaxProfile.empty
          : TrainingMaxProfile.fromJson(
              jsonDecode(collection.trainingMaxProfileJson!)
                  as Map<String, dynamic>,
            ),
      engineState:
          collection.engineStateJson == null
          ? const {}
          : jsonDecode(collection.engineStateJson!) as Map<String, dynamic>,
      states: collection.currentStatesJson
          .map((encoded) => TrainingState.fromJson(jsonDecode(encoded)))
          .toList(),
    );
  }

  Future<TrainingMaxSetupRequirement?> activationRequirementForTemplate(
    String templateId,
  ) async {
    await ensureDefaultProgramSeeded();
    final existingInstance = await fetchInstanceForTemplate(templateId);
    if (existingInstance != null) {
      return null;
    }

    final template = await fetchTemplate(templateId);
    if (template == null || template.requiredTrainingMaxKeys.isEmpty) {
      return null;
    }

    return TrainingMaxSetupRequirement(
      templateId: template.id,
      templateName: template.name,
      liftKeys: template.requiredTrainingMaxKeys,
    );
  }

  Future<StoredTrainingInstance> activateTemplate(
    String templateId, {
    TrainingMaxProfile trainingMaxProfile = TrainingMaxProfile.empty,
  }) async {
    await ensureDefaultProgramSeeded();
    final existingInstance = await fetchInstanceForTemplate(templateId);
    final instance =
        existingInstance ??
        await _createInstanceForTemplate(
          templateId: templateId,
          preferredInstanceId: _defaultInstanceIdForTemplate(templateId),
          trainingMaxProfile: trainingMaxProfile,
        );
    await saveActiveInstanceId(instance.instanceId);
    return instance;
  }

  // ---------- Instances ---------- //

  Future<void> saveInstance(StoredTrainingInstance data) async {
    final encodedStates = data.states
        .map((state) => jsonEncode(state.toJson()))
        .toList();
    final existing = await _database.instanceCollections.getByInstanceId(
      data.instanceId,
    );

    final instance = InstanceCollection()
      ..instanceId = data.instanceId
      ..templateId = data.templateId
      ..currentStatesJson = encodedStates
      ..trainingMaxProfileJson = jsonEncode(data.trainingMaxProfile.toJson())
      ..engineStateJson = jsonEncode(data.engineState)
      ..currentWorkoutIndex = data.currentWorkoutIndex
      ..createdAt = existing?.createdAt ?? DateTime.now()
      ..lastModifiedAt = DateTime.now();

    await _database.writeTxn(() async {
      await _database.instanceCollections.putByInstanceId(instance);
    });
  }

  Future<StoredTrainingInstance?> fetchInstance(String instanceId) async {
    final instance = await _database.instanceCollections.getByInstanceId(
      instanceId,
    );
    if (instance == null) return null;

    return StoredTrainingInstance(
      instanceId: instance.instanceId,
      templateId: instance.templateId,
      currentWorkoutIndex: instance.currentWorkoutIndex,
      trainingMaxProfile:
          instance.trainingMaxProfileJson == null
          ? TrainingMaxProfile.empty
          : TrainingMaxProfile.fromJson(
              jsonDecode(instance.trainingMaxProfileJson!)
                  as Map<String, dynamic>,
            ),
      engineState:
          instance.engineStateJson == null
          ? const {}
          : jsonDecode(instance.engineStateJson!) as Map<String, dynamic>,
      states: instance.currentStatesJson
          .map((encoded) => TrainingState.fromJson(jsonDecode(encoded)))
          .toList(),
    );
  }

  // ---------- Workflow Logs ---------- //

  Future<void> logWorkout(WorkoutLog logRecord) async {
    final encodedLog = jsonEncode(logRecord.toJson());

    final collection = WorkoutLogCollection()
      ..logId =
          '${logRecord.instanceId}_${logRecord.workoutId}_${logRecord.completedAt.millisecondsSinceEpoch}'
      ..instanceId = logRecord.instanceId
      ..workoutId = logRecord.workoutId
      ..workoutName = logRecord.workoutName
      ..rawJsonPayload = encodedLog
      ..completedAt = logRecord.completedAt;

    await _database.writeTxn(() async {
      await _database.workoutLogCollections.putByLogId(collection);
    });
  }

  Future<List<WorkoutLog>> fetchWorkoutLogs(String instanceId) async {
    final collections = await _database.workoutLogCollections.where().findAll();
    final logs = collections
        .where((collection) => collection.instanceId == instanceId)
        .map(
          (collection) =>
              WorkoutLog.fromJson(jsonDecode(collection.rawJsonPayload)),
        )
        .toList();
    logs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return logs;
  }

  Future<List<WorkoutLog>> fetchAllWorkoutLogs() async {
    final collections = await _database.workoutLogCollections.where().findAll();
    final logs = collections
        .map(
          (collection) =>
              WorkoutLog.fromJson(jsonDecode(collection.rawJsonPayload)),
        )
        .toList();
    logs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return logs;
  }

  Future<int> _instanceCountForTemplate(String templateId) async {
    final instances = await _database.instanceCollections
        .filter()
        .templateIdEqualTo(templateId)
        .findAll();
    return instances.length;
  }

  StoredTemplateRecord _toStoredTemplateRecord(
    TemplateCollection collection,
    int instanceCount,
  ) {
    return StoredTemplateRecord(
      template: PlanTemplate.fromJson(jsonDecode(collection.rawJsonPayload)),
      isBuiltIn: collection.isBuiltIn,
      sourceTemplateId: collection.sourceTemplateId,
      createdAt: collection.createdAt,
      lastModifiedAt: collection.lastModifiedAt,
      instanceCount: instanceCount,
    );
  }

  String _slugifyTemplateId(String value) {
    final slug = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'shared-template' : slug;
  }

  String _generatedTemplateId(String name, {String? fallbackSourceId}) {
    final seed = _slugifyTemplateId(name);
    final base = seed == 'shared-template'
        ? _slugifyTemplateId(fallbackSourceId ?? name)
        : seed;
    return '$base-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _syncBuiltInTemplate({
    required String templateId,
    required Future<PlanTemplate> Function() loadTemplate,
  }) async {
    await saveTemplate(await loadTemplate(), isBuiltIn: true);
  }

  Future<void> _purgeLegacyBuiltInInstanceIfNeeded(String instanceId) async {
    final instance = await fetchInstance(instanceId);
    if (instance == null || instance.trainingMaxProfile.isNotEmpty) {
      return;
    }

    await _database.writeTxn(() async {
      await _database.instanceCollections.deleteByInstanceId(instanceId);
    });

    final activeInstanceId = await fetchActiveInstanceId();
    if (activeInstanceId == instanceId) {
      await clearActiveInstanceId();
    }
  }

  Future<StoredTrainingInstance> _createInstanceForTemplate({
    required String templateId,
    required String preferredInstanceId,
    required TrainingMaxProfile trainingMaxProfile,
  }) async {
    final template = await fetchTemplate(templateId);
    if (template == null) {
      throw StateError('Template not found for instance creation: $templateId');
    }
    if (template.requiredTrainingMaxKeys.isNotEmpty &&
        trainingMaxProfile.isEmpty) {
      throw StateError(
        'Training max setup required before activating ${template.name}.',
      );
    }

    final instance = StoredTrainingInstance(
      instanceId: preferredInstanceId,
      templateId: templateId,
      currentWorkoutIndex: 0,
      trainingMaxProfile: trainingMaxProfile,
      engineState: buildInitialEngineState(template),
      states: buildStarterStatesForTemplate(
        template,
        trainingMaxProfile: trainingMaxProfile,
      ),
    );
    await saveInstance(instance);
    return instance;
  }

  String _defaultInstanceIdForTemplate(String templateId) {
    if (templateId == GzclpSeed.templateId) {
      return GzclpSeed.instanceId;
    }
    if (templateId == JackedAndTanSeed.templateId) {
      return JackedAndTanSeed.instanceId;
    }
    return 'instance-$templateId';
  }
}

class StoredTemplateRecord {
  StoredTemplateRecord({
    required this.template,
    required this.isBuiltIn,
    required this.sourceTemplateId,
    required this.createdAt,
    required this.lastModifiedAt,
    required this.instanceCount,
  });

  final PlanTemplate template;
  final bool isBuiltIn;
  final String? sourceTemplateId;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final int instanceCount;

  bool get isUserOwned => !isBuiltIn;
}

class StoredTrainingInstance {
  StoredTrainingInstance({
    required this.instanceId,
    required this.templateId,
    required this.currentWorkoutIndex,
    this.trainingMaxProfile = TrainingMaxProfile.empty,
    this.engineState = const {},
    required this.states,
  });

  final String instanceId;
  final String templateId;
  final int currentWorkoutIndex;
  final TrainingMaxProfile trainingMaxProfile;
  final Map<String, dynamic> engineState;
  final List<TrainingState> states;

  StoredTrainingInstance copyWith({
    String? instanceId,
    String? templateId,
    int? currentWorkoutIndex,
    TrainingMaxProfile? trainingMaxProfile,
    Map<String, dynamic>? engineState,
    List<TrainingState>? states,
  }) {
    return StoredTrainingInstance(
      instanceId: instanceId ?? this.instanceId,
      templateId: templateId ?? this.templateId,
      currentWorkoutIndex: currentWorkoutIndex ?? this.currentWorkoutIndex,
      trainingMaxProfile: trainingMaxProfile ?? this.trainingMaxProfile,
      engineState: engineState ?? this.engineState,
      states: states ?? this.states,
    );
  }
}

class TrainingMaxSetupRequirement {
  const TrainingMaxSetupRequirement({
    required this.templateId,
    required this.templateName,
    required this.liftKeys,
  });

  final String templateId;
  final String templateName;
  final List<String> liftKeys;
}
