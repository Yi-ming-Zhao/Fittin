import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/presentation/screens/progress_analytics_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ExerciseLibrary exerciseLibrary;

  setUpAll(() async {
    exerciseLibrary = await ExerciseLibraryLoader().load();
  });

  testWidgets('analytics screen renders exercise progress and formula picker', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    await repository.logWorkout(
      WorkoutLog(
        instanceId: 'a',
        workoutId: 'day1',
        workoutName: 'Day 1',
        dayLabel: 'Day 1',
        completedAt: DateTime(2026, 1, 1),
        exercises: [
          const ExerciseLog(
            exerciseId: 'squat',
            exerciseName: 'Squat',
            stageId: 'stage-1',
            sets: [
              SetLog(
                role: 'working',
                targetReps: 5,
                completedReps: 5,
                targetWeight: 100,
                weight: 100,
                isCompleted: true,
              ),
            ],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          exerciseLibraryProvider.overrideWith((ref) async => exerciseLibrary),
        ],
        child: const MaterialApp(home: ProgressAnalyticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trends & Analytics'), findsOneWidget);
    expect(find.text('Squat'), findsWidgets);
    expect(find.text('Epley'), findsOneWidget);

    await tester.tap(find.text('Epley'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Brzycki').last);
    await tester.pumpAndSettle();

    expect(
      ProviderScope.containerOf(
        tester.element(find.byType(ProgressAnalyticsScreen)),
      ).read(analyticsFormulaProvider),
      OneRepMaxFormula.brzycki,
    );

    await _openExerciseDetails(tester, 'Squat');
    expect(find.text('Active formula: Brzycki'), findsOneWidget);
    expect(find.text('100.0 kg × 5 reps'), findsWidgets);
    expect(find.text('No single recorded yet'), findsWidgets);
    expect(find.textContaining('Actual 1RM'), findsNothing);
    expect(find.textContaining(' x '), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('analytics screen localizes premium copy to Chinese', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    await repository.saveAppLocale(AppLocale.zh);
    await repository.logWorkout(
      WorkoutLog(
        instanceId: 'a',
        workoutId: 'day1',
        workoutName: 'Day 1',
        dayLabel: 'Day 1',
        completedAt: DateTime(2026, 1, 1),
        exercises: [
          const ExerciseLog(
            exerciseId: 'squat',
            exerciseName: 'Squat',
            stageId: 'stage-1',
            sets: [
              SetLog(
                role: 'working',
                targetReps: 5,
                completedReps: 5,
                targetWeight: 100,
                weight: 100,
                isCompleted: true,
              ),
            ],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          exerciseLibraryProvider.overrideWith((ref) async => exerciseLibrary),
        ],
        child: const MaterialApp(home: ProgressAnalyticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('趋势与分析'), findsOneWidget);
    expect(find.text('训练一致性'), findsOneWidget);
    expect(find.text('深蹲'), findsWidgets);
    expect(find.text('Trends & Analytics'), findsNothing);
    expect(find.text('Training consistency'), findsNothing);
    expect(find.text('Squat'), findsNothing);

    await _openExerciseDetails(tester, '深蹲');
    expect(find.text('当前公式：Epley'), findsOneWidget);
    expect(find.text('100.0 公斤 × 5 次'), findsWidgets);
    expect(find.text('暂无单次记录'), findsWidgets);
    expect(find.textContaining('真实 1RM'), findsNothing);
    expect(find.textContaining(' x '), findsNothing);
    expect(find.textContaining('Active formula'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  for (final testCase in const [
    (
      locale: AppLocale.en,
      message: 'Unable to load progress analytics right now. Please try again.',
    ),
    (locale: AppLocale.zh, message: '暂时无法加载进步分析，请稍后重试。'),
  ]) {
    testWidgets(
      'analytics load failure uses ${testCase.locale.code} product copy',
      (tester) async {
        final repository = InMemoryDatabaseRepository();
        await repository.saveAppLocale(testCase.locale);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseRepositoryProvider.overrideWithValue(repository),
              progressAnalyticsOverviewProvider.overrideWith((ref) async {
                throw StateError('secret backend detail');
              }),
            ],
            child: const MaterialApp(home: ProgressAnalyticsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(testCase.message), findsOneWidget);
        expect(find.textContaining('secret backend detail'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> _openExerciseDetails(
  WidgetTester tester,
  String exerciseName,
) async {
  final scrollable = find
      .byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      )
      .first;
  Finder card() => find.ancestor(
    of: find.text(exerciseName),
    matching: find.byWidgetPredicate(
      (widget) => widget is DashboardSurfaceCard && widget.onTap != null,
    ),
  );

  for (var attempt = 0; attempt < 12 && card().evaluate().isEmpty; attempt++) {
    await tester.drag(scrollable, const Offset(0, -240));
    await tester.pump();
  }
  expect(card(), findsOneWidget);
  await tester.tap(card());
  await tester.pumpAndSettle();
}
