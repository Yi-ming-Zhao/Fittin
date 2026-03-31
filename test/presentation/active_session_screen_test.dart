import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/presentation/screens/active_session_screen.dart';

import '../support/fake_today_workout_gateway.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('active session screen renders compact workout console', (
    WidgetTester tester,
  ) async {
    final gateway = FakeTodayWorkoutGateway();
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(
          InMemoryDatabaseRepository(),
        ),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    await container.read(activeSessionProvider.notifier).startOrResumeSession();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ActiveSessionScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Set 1 / 2'), findsOneWidget);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Conclude Workout'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm workout conclusion?'), findsOneWidget);
    expect(gateway.concludedSession, isNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(gateway.concludedSession, isNull);

    await tester.tap(find.text('Conclude Workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Conclude Workout').last);
    await tester.pumpAndSettle();
    expect(gateway.concludedSession, isNotNull);
  });
}
