import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/domain/exercise_performance_profile.dart';
import 'package:fittin_v2/src/domain/plan_start_load_review.dart';
import 'package:fittin_v2/src/domain/starting_load_estimator.dart';
import 'package:fittin_v2/src/presentation/widgets/plan_start_load_review_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows source and warnings while preserving edited provenance', (
    tester,
  ) async {
    PlanStartLoadReview? confirmed;
    final review = _review();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  confirmed = await showDialog<PlanStartLoadReview>(
                    context: context,
                    builder: (_) => PlanStartLoadReviewDialog(review: review),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Review starting loads'), findsOneWidget);
    expect(find.textContaining('same-exercise 5RM record'), findsOneWidget);
    expect(find.textContaining('Low confidence'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('plan-start-load-row-occurrence')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('plan-start-load-row-occurrence')),
      '55',
    );
    await tester.tap(find.text('Confirm & start'));
    await tester.pumpAndSettle();

    final entry = confirmed!.entries.single;
    expect(entry.confirmedWeightKg, 55);
    expect(entry.wasEdited, isTrue);
    expect(entry.recommendation!.suggestedWeightKg, 50);
    expect(entry.recommendation!.sourceWorkoutReference, 'source-log');
  });
}

PlanStartLoadReview _review() {
  return PlanStartLoadReview(
    templateId: 'template',
    catalogVersion: '1.0.0',
    profileFormulaKey: 'epley',
    profileSourceFingerprint: 'abcd1234',
    entries: [
      PlanStartLoadEntry(
        exerciseOccurrenceId: 'row-occurrence',
        exerciseDefinitionId: 'barbell_row',
        exerciseName: 'Barbell Row',
        kind: PlanStartLoadEntryKind.reviewable,
        planWeightKg: null,
        confirmedWeightKg: 50,
        targetReps: 5,
        targetRir: 0,
        recommendation: PlanStartRecommendationSnapshot(
          suggestedWeightKg: 50,
          rawWeightKg: 60,
          source: StartingLoadSource.sameExerciseObservedRm,
          confidence: PerformanceConfidence.low,
          safetyFactor: 0.85,
          warnings: const [
            StartingLoadWarningCode.editableSuggestion,
            StartingLoadWarningCode.lowConfidence,
          ],
          sourceExerciseId: 'barbell_row',
          sourceWorkoutReference: 'source-log',
          sourceCompletedAt: DateTime(2026, 1, 1),
          sourceSetIndex: 0,
          sourceValueKg: 60,
          sourceObservedReps: 5,
          sourceFormulaKey: null,
          conversionFormulaKey: null,
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
