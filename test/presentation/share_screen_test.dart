import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/data/seeds/powerbuilding_4day_12week_seed.dart';
import 'package:fittin_v2/src/presentation/screens/share_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
