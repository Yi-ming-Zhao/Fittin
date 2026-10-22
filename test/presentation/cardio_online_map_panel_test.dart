import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/data/cardio_online_map.dart';
import 'package:fittin_v2/src/domain/models/cardio_recording.dart';
import 'package:fittin_v2/src/presentation/widgets/cardio_online_map_panel.dart';

void main() {
  testWidgets('account switch clears personal key and rejects stale consent', (
    tester,
  ) async {
    final owner = StateProvider<String?>((ref) => 'alice');
    final map = _FailingMap();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => ref.watch(owner)),
          cardioOnlineMapProvider.overrideWithValue(map),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CardioOnlineMapPanel(
              point: RoutePoint(
                latitude: 39.9,
                longitude: 116.4,
                timestamp: DateTime.utc(2026),
              ),
              ownerUserId: 'alice',
              chinese: false,
            ),
          ),
        ),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    container.read(cardioMapKeyProvider.notifier).state = 'a' * 32;
    await tester.tap(find.text('Online area map'));
    await tester.pumpAndSettle();
    container.read(owner.notifier).state = 'bob';
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agree & load'));
    await tester.pumpAndSettle();
    expect(map.calls, 0);
    expect(container.read(cardioMapKeyProvider), isNull);
    expect(find.text('Online area map'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'map defaults off; cancel never sends coordinates; failure retains controls',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final map = _FailingMap();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserIdProvider.overrideWithValue('alice'),
            cardioOnlineMapProvider.overrideWithValue(map),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CardioOnlineMapPanel(
                point: RoutePoint(
                  latitude: 39.9,
                  longitude: 116.4,
                  timestamp: DateTime.utc(2026),
                ),
                ownerUserId: 'alice',
                chinese: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(map.calls, 0);
      await tester.tap(find.text('Online area map'));
      await tester.pumpAndSettle();
      expect(find.textContaining('one position'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(map.calls, 0);
      await tester.tap(find.text('Online area map'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'a' * 32);
      await tester.tap(find.text('Agree & load'));
      await tester.pumpAndSettle();
      expect(map.calls, 1);
      expect(
        find.textContaining('Offline recording is unaffected'),
        findsOneWidget,
      );
      await tester.tap(find.text('Close & clear key'));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      expect(container.read(cardioMapKeyProvider), isNull);
      expect(find.text('Online area map'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _FailingMap extends CardioOnlineMap {
  int calls = 0;
  @override
  Future<Uint8List> load({
    required String key,
    required RoutePoint point,
    int zoom = 15,
    bool Function()? isCurrent,
  }) async {
    calls++;
    throw const CardioMapUnavailable();
  }
}
