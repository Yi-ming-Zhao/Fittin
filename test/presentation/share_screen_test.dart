import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/data/seeds/powerbuilding_4day_12week_seed.dart';
import 'package:fittin_v2/src/presentation/screens/share_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_today_workout_gateway.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plan QR scales inside a 320px phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
        ],
        child: const MaterialApp(
          home: ShareScreen(planTemplate: fakePlanTemplate),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final qr = find.byKey(const ValueKey('plan-share-qr'));
    expect(qr, findsOneWidget);
    final rect = tester.getRect(qr);
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(320));
    expect(rect.width, lessThanOrEqualTo(240));
    expect(tester.takeException(), isNull);
  });

  testWidgets('oversized built-in plan shows a recoverable share fallback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final template = await tester.runAsync(
      Powerbuilding4Day12WeekSeed.loadTemplate,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
        ],
        child: MaterialApp(home: ShareScreen(planTemplate: template!)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('plan-share-too-large')), findsOneWidget);
    expect(find.byKey(const ValueKey('plan-share-qr')), findsNothing);
    expect(
      find.byKey(const ValueKey('copy-plan-share-payload')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
