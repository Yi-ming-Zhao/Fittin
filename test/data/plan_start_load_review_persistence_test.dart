import 'dart:io';

import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/web_database_repository.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/domain/exercise_performance_profile.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/plan_start_load_review.dart';
import 'package:fittin_v2/src/domain/starting_load_estimator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../support/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'native datastore restores confirmed load and provenance metadata',
    () async {
      final testStore = await openTestIsar('plan_start_load_review_native');
      final isar = testStore.isar;
      final directory = testStore.directory;
      addTearDown(() => _closeStore(isar, directory));

      final writer = DatabaseRepository(isar);
      await writer.saveTemplate(_template());
      final created = await writer.activateTemplate(
        'load-review-template',
        planStartLoadReview: _review(),
      );
      final readerAfterReload = DatabaseRepository(isar);
      final restored = await readerAfterReload.fetchInstance(
        created.instanceId,
      );

      _expectRestored(restored!);
    },
  );

  test(
    'web datastore restores confirmed load and provenance metadata',
    () async {
      final store = _MemoryWebLocalStore();
      final writer = WebDatabaseRepository(store);
      await writer.saveTemplate(_template());
      final created = await writer.activateTemplate(
        'load-review-template',
        planStartLoadReview: _review(),
      );
      final readerAfterReload = WebDatabaseRepository(store);
      final restored = await readerAfterReload.fetchInstance(
        created.instanceId,
      );

      _expectRestored(restored!);
    },
  );
}

void _expectRestored(StoredTrainingInstance instance) {
  expect(instance.states.single.baseWeight, 37.5);
  final review = instance.planStartLoadReview!;
  final entry = review.entries.single;
  expect(review.profileSourceFingerprint, 'deadbeef');
  expect(entry.confirmedWeightKg, 37.5);
  expect(entry.wasEdited, isTrue);
  expect(entry.recommendation!.suggestedWeightKg, 35);
  expect(entry.recommendation!.sourceWorkoutReference, 'old-log');
  expect(
    entry.recommendation!.warnings,
    contains(StartingLoadWarningCode.lowConfidence),
  );
}

PlanTemplate _template() {
  return PlanTemplate(
    id: 'load-review-template',
    name: 'Load Review',
    description: 'Persistence test',
    phases: [
      Phase(
        id: 'phase',
        name: 'Phase',
        workouts: [
          Workout(
            id: 'day',
            name: 'Day',
            exercises: [
              Exercise(
                id: 'row-occurrence',
                exerciseId: 'barbell_row',
                name: 'Barbell Row',
                stages: const [
                  SetScheme(
                    id: 'stage',
                    name: 'Stage',
                    sets: [SetDefinition(targetReps: 8, intensity: 1)],
                    rules: [],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

PlanStartLoadReview _review() {
  return PlanStartLoadReview(
    templateId: 'load-review-template',
    catalogVersion: '1.0.0',
    profileFormulaKey: 'epley',
    profileSourceFingerprint: 'deadbeef',
    entries: [
      PlanStartLoadEntry(
        exerciseOccurrenceId: 'row-occurrence',
        exerciseDefinitionId: 'barbell_row',
        exerciseName: 'Barbell Row',
        kind: PlanStartLoadEntryKind.reviewable,
        planWeightKg: null,
        confirmedWeightKg: 37.5,
        targetReps: 8,
        targetRir: 0,
        recommendation: PlanStartRecommendationSnapshot(
          suggestedWeightKg: 35,
          rawWeightKg: 42,
          source: StartingLoadSource.sameExerciseEstimatedOneRepMax,
          confidence: PerformanceConfidence.low,
          safetyFactor: 0.85,
          warnings: const [StartingLoadWarningCode.lowConfidence],
          sourceExerciseId: 'barbell_row',
          sourceWorkoutReference: 'old-log',
          sourceCompletedAt: DateTime(2026, 1, 1),
          sourceSetIndex: 0,
          sourceValueKg: 50,
          sourceObservedReps: null,
          sourceFormulaKey: 'epley',
          conversionFormulaKey: 'epley',
          anchorFamilyKey: null,
          ratioLower: null,
          ratioCenter: null,
          ratioUpper: null,
          ratioConfidenceKey: null,
          ratioEvidenceGradeKey: null,
          catalogVersion: '1.0.0',
          profileCatalogVersion: '1.0.0',
        ),
      ),
    ],
  );
}

Future<void> _closeStore(Isar isar, Directory directory) async {
  await isar.close(deleteFromDisk: true);
  if (await directory.exists()) {
    await directory.delete(recursive: true);
  }
}

class _MemoryWebLocalStore extends WebLocalStore {
  final Map<String, Map<String, Map<String, dynamic>>> _records = {};

  @override
  Future<Map<String, dynamic>?> getRecord(String storeName, String key) async {
    final record = _records[storeName]?[key];
    return record == null ? null : Map<String, dynamic>.from(record);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllRecords(String storeName) async {
    return _records[storeName]?.values
            .map((record) => Map<String, dynamic>.from(record))
            .toList() ??
        const [];
  }

  @override
  Future<void> putRecord(
    String storeName,
    String key,
    Map<String, dynamic> value,
  ) async {
    (_records[storeName] ??= {})[key] = Map<String, dynamic>.from(value);
  }

  @override
  Future<void> deleteRecord(String storeName, String key) async {
    _records[storeName]?.remove(key);
  }
}
