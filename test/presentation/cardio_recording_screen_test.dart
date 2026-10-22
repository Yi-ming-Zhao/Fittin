import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/cardio_route_sync.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/cardio_recording_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/user_content_provider.dart';
import 'package:fittin_v2/src/data/cardio_location_source.dart';
import 'package:fittin_v2/src/data/cardio_recording_store.dart';
import 'package:fittin_v2/src/domain/models/cardio.dart';
import 'package:fittin_v2/src/domain/models/cardio_recording.dart';
import 'package:fittin_v2/src/presentation/screens/cardio_recording_screen.dart';
import 'package:fittin_v2/src/presentation/screens/cardio_route_review_screen.dart';
import 'package:fittin_v2/src/presentation/screens/profile_hub_screen.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  testWidgets(
    'cloud inventory is private and deletion needs separate confirmation',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final remote = _CloudInventory();
      final store = CardioRecordingStore(_RouteDocuments());
      final service = CardioRouteSync(
        local: store,
        remote: remote,
        owner: 'alice',
        checkOwner: () {},
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(
              InMemoryDatabaseRepository(),
            ),
            currentUserIdProvider.overrideWithValue('alice'),
            appLocaleProvider.overrideWith(
              (ref) => AppLocaleNotifier(ref, initialLocale: AppLocale.en),
            ),
            cardioRouteSyncProvider.overrideWithValue(service),
            cardioRecordingStoreProvider.overrideWithValue(store),
            localCardioSessionsProvider.overrideWith((ref) async => []),
            cardioRecordsProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: CloudCardioRoutesScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(remote.writes, 0);
      await tester.tap(find.text('Remote run'));
      await tester.pumpAndSettle();
      final manage = find.text('Manage private cloud route');
      await tester.scrollUntilVisible(manage, 200);
      await tester.tap(manage);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete cloud route and incomplete uploads'));
      await tester.pumpAndSettle();
      expect(remote.writes, 0);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(remote.writes, 0);
      await tester.tap(manage);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete cloud route and incomplete uploads'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(remote.writes, 1);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'privacy entry manages orphaned local routes without recreating summaries',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final database = InMemoryDatabaseRepository();
      final store = CardioRecordingStore(_RouteDocuments());
      final session = CardioRecordingSession(
        id: 'deleted-summary',
        ownerUserId: null,
        sport: CardioSport.running,
        startedAt: DateTime.utc(2026, 10, 21),
        phase: CardioRecordingPhase.finished,
        activityName: 'Local run',
        activityTypeId: 'cardio:running',
        activeMilliseconds: 60000,
        elapsedMilliseconds: 60000,
        distanceMeters: 100,
      );
      await store.checkpoint(
        session,
        expectedRevision: 0,
        batchId: 'route',
        points: [
          RoutePoint(
            latitude: 30,
            longitude: 120,
            timestamp: session.startedAt,
            accuracyMeters: 5,
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(database),
            appLocaleProvider.overrideWith(
              (ref) => AppLocaleNotifier(ref, initialLocale: AppLocale.en),
            ),
            cardioRecordingStoreProvider.overrideWithValue(store),
          ],
          child: const MaterialApp(home: DataPrivacyScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('privacy-local-cardio-routes')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LocalCardioRoutesScreen), findsOneWidget);
      await tester.tap(find.text('Local run'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Edit summary'), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('cardio-export-route')),
        250,
      );
      expect(find.byKey(const ValueKey('cardio-export-route')), findsOneWidget);
      final delete = find.text('Delete local route and laps');
      await tester.scrollUntilVisible(delete, 150);
      await tester.tap(delete);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(await store.read(session.id, ownerUserId: null), isNotNull);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(FilledButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(await store.read(session.id, ownerUserId: null), isNull);
      expect(tester.takeException(), isNull);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      expect(await container.read(cardioRecordsProvider.future), isEmpty);
    },
  );
  for (final size in [
    const Size(320, 568),
    const Size(390, 568),
    const Size(390, 844),
    const Size(390, 926),
  ]) {
    testWidgets('cardio recording states fit themes and locales at $size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = CardioRecordingStore(_EmptyDocuments());
      for (final locale in AppLocale.values) {
        for (final palette in FittinPaletteRegistry.ids) {
          final theme = FittinPaletteRegistry.themeOf(palette);
          for (final phase in [
            null,
            CardioRecordingPhase.recording,
            CardioRecordingPhase.paused,
            CardioRecordingPhase.finished,
          ]) {
            final session = phase == null
                ? null
                : CardioRecordingSession(
                    id: 'test',
                    ownerUserId: null,
                    sport: CardioSport.running,
                    startedAt: DateTime.utc(2026),
                    phase: phase,
                    elapsedMilliseconds: 4500000,
                    activeMilliseconds: 4000000,
                    distanceMeters: 12345,
                    activityTypeId: 'cardio:running',
                    activityName: locale == AppLocale.zh ? '跑步' : 'Running',
                  );
            await tester.pumpWidget(
              ProviderScope(
                key: ValueKey('$locale-$palette-$phase'),
                overrides: [
                  databaseRepositoryProvider.overrideWithValue(
                    InMemoryDatabaseRepository(),
                  ),
                  appLocaleProvider.overrideWith(
                    (ref) => AppLocaleNotifier(ref, initialLocale: locale),
                  ),
                  resolvedFittinThemeProvider.overrideWithValue(theme),
                  cardioRecordingStoreProvider.overrideWithValue(store),
                  localCardioSessionsProvider.overrideWith((ref) async => []),
                  cardioRecordingProvider.overrideWith(
                    (ref) => _SnapshotController(store, session),
                  ),
                ],
                child: MaterialApp(
                  theme: ThemeData(colorScheme: theme.colorScheme),
                  home: CardioRecordingScreen(
                    activity: BuiltInCardioActivities.byId('cardio:running'),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$locale $palette $phase',
            );
            if (phase == null) {
              final button = find.byKey(const ValueKey('cardio-start'));
              expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
            } else {
              final primary = find.byKey(
                ValueKey(
                  phase == CardioRecordingPhase.finished
                      ? 'cardio-save'
                      : 'cardio-pause-resume',
                ),
              );
              expect(primary.hitTestable(), findsOneWidget);
              expect(
                tester.getRect(primary).bottom,
                lessThanOrEqualTo(size.height),
              );
              expect(tester.getSize(primary).height, greaterThanOrEqualTo(48));
              if (phase == CardioRecordingPhase.recording) {
                await tester.tap(
                  find.byKey(const ValueKey('cardio-screen-lock')),
                );
                await tester.pumpAndSettle();
                final unlock = find.byKey(const ValueKey('cardio-unlock'));
                expect(unlock.hitTestable(), findsOneWidget);
                expect(tester.getSize(unlock).height, greaterThanOrEqualTo(48));
                expect(find.text('1:06:40'), findsOneWidget);
                await tester.longPress(
                  find.text('1:06:40'),
                  warnIfMissed: false,
                );
                await tester.pumpAndSettle();
                expect(unlock, findsOneWidget);
                await tester.tap(unlock);
                await tester.pumpAndSettle();
                expect(unlock, findsOneWidget);
                await tester.longPress(unlock);
                await tester.pumpAndSettle();
                expect(unlock, findsNothing);
                expect(primary.hitTestable(), findsOneWidget);
                expect(tester.takeException(), isNull);
              }
            }
          }
        }
      }
    });
  }

  testWidgets(
    'local route review is accessible at 320px with large text and explicit export consent',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final session = CardioRecordingSession(
        id: 'cardio-record:test',
        ownerUserId: null,
        sport: CardioSport.running,
        startedAt: DateTime.utc(2026),
        phase: CardioRecordingPhase.finished,
        activeMilliseconds: 600000,
        elapsedMilliseconds: 700000,
        distanceMeters: 1000,
        activityName: 'Running',
      );
      final record = CardioRecord(
        id: session.id,
        activityTypeId: 'cardio:running',
        activityName: 'Running',
        startedAt: session.startedAt,
        metrics: const {
          CardioMetricKey.durationSeconds: 600,
          CardioMetricKey.distanceMeters: 1000,
        },
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(
              InMemoryDatabaseRepository(),
            ),
            cardioRecordingStoreProvider.overrideWithValue(
              CardioRecordingStore(_EmptyDocuments()),
            ),
            localCardioSessionsProvider.overrideWith(
              (ref) async => [StoredCardioSession(session, 1, 1)],
            ),
            cardioRecordsProvider.overrideWith((ref) async => [record]),
          ],
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.8)),
              child: child!,
            ),
            home: CardioRouteReviewScreen(
              record: record,
              ownerUserId: null,
              onEdit: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final export = find.byKey(const ValueKey('cardio-export-route'));
      await tester.scrollUntilVisible(export, 300);
      await tester.pumpAndSettle();
      await Scrollable.ensureVisible(
        tester.element(export),
        alignment: 0.5,
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();
      await tester.tap(export);
      await tester.pumpAndSettle();
      expect(find.text('Export precise route?'), findsOneWidget);
      expect(find.textContaining('may reveal your home'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final cancel = MaterialLocalizations.of(
        tester.element(find.byType(AlertDialog)),
      ).cancelButtonLabel;
      await tester.tap(find.text(cancel));
      await tester.pumpAndSettle();
      expect(find.text('Export precise route?'), findsNothing);
    },
  );
}

class _SnapshotController extends CardioRecordingController {
  _SnapshotController(
    CardioRecordingStore store,
    CardioRecordingSession? snapshot,
  ) : super(
        store: store,
        location: _NoLocation(),
        ownerUserId: null,
        onSaved: () {},
      ) {
    state = CardioRecordingView(session: snapshot, accuracyMeters: 5);
  }
}

class _NoLocation implements CardioLocationSource {
  @override
  bool get supportsTracking => true;
  @override
  Future<void> requestPermission() async {}
  @override
  Stream<RoutePoint> positions({
    required bool chinese,
    bool preparing = false,
  }) => const Stream.empty();
}

class _EmptyDocuments implements CardioLocalDocuments {
  @override
  Future<T> transaction<T>(Future<T> Function() action) => action();
  @override
  Future<Map<String, dynamic>?> read(String key) async => null;
  @override
  Future<List<Map<String, dynamic>>> list(String prefix) async => [];
  @override
  Future<void> put(String key, Map<String, dynamic> value) async {}
  @override
  Future<void> delete(String key) async {}
}

class _RouteDocuments implements CardioLocalDocuments {
  final _rows = <String, Map<String, dynamic>>{};
  @override
  Future<T> transaction<T>(Future<T> Function() action) => action();
  @override
  Future<Map<String, dynamic>?> read(String key) async => _rows[key];
  @override
  Future<List<Map<String, dynamic>>> list(String prefix) async => [
    for (final entry in _rows.entries)
      if (entry.key.startsWith(prefix)) entry.value,
  ];
  @override
  Future<void> put(String key, Map<String, dynamic> value) async {
    _rows[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _rows.remove(key);
  }
}

class _CloudInventory implements CardioRouteRemote {
  int writes = 0;
  @override
  Future<Map<String, dynamic>> list({String? after}) async => {
    'items': [
      {
        'id': 'cardio-record:11111111-1111-4111-8111-111111111111',
        'version': 1,
        'activityName': 'Remote run',
        'startedAt': '2026-10-21T00:00:00Z',
      },
    ],
    'nextCursor': '',
  };
  @override
  Future<Map<String, dynamic>?> manifest(String id) async => {'version': 1};
  @override
  Future<void> delete(String id, int version) async {
    expect(version, 1);
    writes++;
  }

  @override
  Future<List<int>> chunk(String id, String hash) async =>
      throw StateError('Unexpected coordinate download');
  @override
  Future<void> uploadChunk(String id, String hash, String data) async =>
      throw StateError('Unexpected upload');
  @override
  Future<Map<String, dynamic>> commit(
    String id,
    Map<String, dynamic> data,
  ) async => throw StateError('Unexpected commit');
}
