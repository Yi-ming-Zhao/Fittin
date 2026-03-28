import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/template_editor_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/presentation/screens/plan_editor_screen.dart';

import '../support/in_memory_database_repository.dart';

class _StubTemplateEditorNotifier extends TemplateEditorNotifier {
  _StubTemplateEditorNotifier(super.ref, PlanTemplate draft) {
    state = TemplateEditorState(draft: draft);
  }

  @override
  Future<void> loadTemplate(String templateId) async {}

  @override
  void createBlankTemplate() {}

  @override
  Future<StoredTemplateRecord?> saveTemplate() async => null;
}

PlanTemplate _buildLinearTemplate() {
  return PlanTemplate(
    id: 'linear-template',
    name: 'Linear Template',
    description: 'Reusable workout structure',
    engineFamily: 'linear_tm',
    scheduleMode: PlanScheduleModes.linear,
    phases: [
      Phase(
        id: 'phase-1',
        name: 'Phase 1',
        workouts: [
          Workout(
            id: 'workout-a',
            name: 'Workout A',
            dayLabel: 'Day 1',
            exercises: [
              Exercise(
                id: 'exercise-1',
                exerciseId: 'squat',
                name: 'Squat',
                stages: [
                  SetScheme(
                    id: 'stage-1',
                    name: 'Stage 1',
                    sets: const [
                      SetDefinition(targetReps: 5, intensity: 0.75),
                    ],
                    rules: const [
                      ProgressionRule(condition: 'on_success', actions: []),
                      ProgressionRule(condition: 'on_failure', actions: []),
                    ],
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

PlanTemplate _buildPeriodizedTemplate() {
  return PlanTemplate(
    id: 'periodized-template',
    name: 'Periodized Template',
    description: 'Week/day slot editor',
    engineFamily: 'periodized_tm',
    scheduleMode: PlanScheduleModes.periodized,
    phases: [
      Phase(
        id: 'phase-1',
        name: 'Phase 1',
        workouts: [
          Workout(
            id: 'workout-a',
            name: 'Workout A',
            dayLabel: 'Day 1',
            exercises: [
              Exercise(
                id: 'exercise-1',
                exerciseId: 'bench',
                name: 'Bench Press',
                stages: [
                  SetScheme(
                    id: 'stage-1',
                    name: 'Week 1',
                    sets: const [
                      SetDefinition(targetReps: 5, intensity: 0.7),
                    ],
                    rules: const [],
                  ),
                  SetScheme(
                    id: 'stage-2',
                    name: 'Week 2',
                    sets: const [
                      SetDefinition(targetReps: 3, intensity: 0.8),
                    ],
                    rules: const [],
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

Future<void> _pumpScreen(
  WidgetTester tester, {
  required PlanTemplate draft,
  bool pushFromHome = false,
}) async {
  final repository = InMemoryDatabaseRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        templateEditorProvider.overrideWith(
          (ref) => _StubTemplateEditorNotifier(ref, draft),
        ),
      ],
      child: MaterialApp(
        home: pushFromHome
            ? Scaffold(
                body: Builder(
                  builder: (context) => Center(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const PlanEditorScreen(templateId: 'ignored'),
                          ),
                        );
                      },
                      child: const Text('Open editor'),
                    ),
                  ),
                ),
              )
            : const PlanEditorScreen(templateId: 'ignored'),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _scrollUntilVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('plan editor keeps linear templates in the reusable workout flow', (
    WidgetTester tester,
  ) async {
    await _pumpScreen(tester, draft: _buildLinearTemplate());

    expect(
      find.text('Linear plans are edited as reusable workout structures.'),
      findsOneWidget,
    );
    expect(find.text('Schedule Mode'), findsOneWidget);
    expect(find.text('Week/Day Slot'), findsNothing);
    expect(find.textContaining('W1D1'), findsNothing);

    await _scrollUntilVisible(tester, find.text('On Success'));
    expect(find.text('On Success'), findsOneWidget);
    expect(find.text('On Failure'), findsOneWidget);

    await _scrollUntilVisible(tester, find.text('Add Workout'));
    expect(find.text('Add Workout'), findsOneWidget);
  });

  testWidgets('plan editor shows a dashboard back button when pushed', (
    WidgetTester tester,
  ) async {
    await _pumpScreen(
      tester,
      draft: _buildLinearTemplate(),
      pushFromHome: true,
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();

    final backButton = find.byKey(const ValueKey('dashboard-header-back'));
    expect(backButton, findsOneWidget);

    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.text('Open editor'), findsOneWidget);
    expect(find.byType(PlanEditorScreen), findsNothing);
  });

  testWidgets('plan editor focuses periodized templates by week and day slot', (
    WidgetTester tester,
  ) async {
    await _pumpScreen(tester, draft: _buildPeriodizedTemplate());

    expect(
      find.text(
        'Edit periodized plans by week/day slot instead of scrolling the whole cycle.',
      ),
      findsOneWidget,
    );
    expect(find.text('On Success'), findsNothing);
    expect(find.text('On Failure'), findsNothing);

    await _scrollUntilVisible(tester, find.text('Week/Day Slot'));
    expect(find.text('Week/Day Slot'), findsOneWidget);
    expect(find.text('D1'), findsOneWidget);
    expect(find.text('W1'), findsOneWidget);
    expect(find.textContaining('W1D1'), findsOneWidget);

    await tester.tap(find.text('W2').first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('W2D1'), findsOneWidget);
    expect(find.text('On Success'), findsNothing);
    expect(find.text('On Failure'), findsNothing);
  });
}
