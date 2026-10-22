import 'dart:async';
import 'package:fittin_v2/src/application/cardio_recording_provider.dart';
import 'package:fittin_v2/src/data/cardio_location_source.dart';
import 'package:fittin_v2/src/data/cardio_recording_store.dart';
import 'package:fittin_v2/src/data/cardio_recording_store_native.dart';
import 'package:fittin_v2/src/domain/models/cardio_recording.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:fittin_v2/src/data/cardio_background_support.dart';
import '../support/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CardioRecordingStore store;
  late _Location location;
  late CardioRecordingController controller;
  setUp(() async {
    final db = await openTestIsar('cardio_controller');
    addTearDown(() async {
      await db.isar.close(deleteFromDisk: true);
      await db.directory.delete(recursive: true);
    });
    store = CardioRecordingStore(IsarCardioLocalDocuments(db.isar));
    location = _Location();
    controller = CardioRecordingController(
      store: store,
      location: location,
      ownerUserId: 'alice',
      onSaved: () {},
    );
  });

  test(
    'background fixes checkpoint without UI timers and keep one subscription',
    () async {
      controller.dispose();
      final clock = _ManualClock();
      var saved = Completer<void>();
      controller = CardioRecordingController(
        store: store,
        location: location,
        ownerUserId: 'alice',
        clock: clock,
        onSaved: () {
          if (!saved.isCompleted) saved.complete();
        },
      );
      await _start(controller);
      final id = controller.state.session!.id;
      saved = Completer<void>();
      controller.didChangeAppLifecycleState(AppLifecycleState.hidden);
      await saved.future;
      expect(location.cancellations, 0);
      saved = Completer<void>();
      clock.milliseconds = 6100;
      location.stream.add(
        RoutePoint(
          latitude: 30,
          longitude: 120,
          timestamp: DateTime.now(),
          accuracyMeters: 5,
        ),
      );
      await saved.future;
      final snapshot = (await store.read(id, ownerUserId: 'alice'))!;
      expect(snapshot.session.activeMilliseconds, 6100);
      expect(
        (await store.route(id, ownerUserId: 'alice').toList()).single,
        hasLength(1),
      );
      expect(location.subscriptions, 1);
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      clock.milliseconds = 7100;
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(controller.state.session!.activeMilliseconds, 7100);
      expect(location.subscriptions, 1);
      await controller.finish();
      expect(location.cancellations, 1);
      controller.dispose();
    },
  );

  test('notification denial does not prevent native recording', () async {
    controller.dispose();
    controller = CardioRecordingController(
      store: store,
      location: location,
      ownerUserId: 'alice',
      onSaved: () {},
      backgroundSupport: _DeniedNotification(),
    );
    await _start(controller);
    expect(controller.state.backgroundStatus!.notificationsEnabled, isFalse);
    expect(controller.state.errorCode, isNull);
    expect(controller.state.session!.phase, CardioRecordingPhase.recording);
    await controller.finish();
    controller.dispose();
  });

  test(
    'late resume permission cannot start service after app is hidden',
    () async {
      await _start(controller);
      await controller.pause();
      location.permission = Completer<void>();
      final resuming = controller.resume();
      await Future<void>.delayed(const Duration(milliseconds: 25));
      controller.didChangeAppLifecycleState(AppLifecycleState.hidden);
      location.permission!.complete();
      await resuming;
      expect(location.subscriptions, 1);
      expect(controller.state.errorCode, 'foreground_required');
      expect(controller.state.session!.phase, CardioRecordingPhase.interrupted);
      controller.dispose();
    },
  );

  test(
    'pause and finish cancel location; checkpoints retain measured points',
    () async {
      await _start(controller);
      final id = controller.state.session!.id;
      expect(location.subscriptions, 1);
      location.stream.add(
        RoutePoint(
          latitude: 30,
          longitude: 120,
          timestamp: DateTime.now(),
          accuracyMeters: 5,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.accuracyMeters, 5);
      await controller.pause();
      expect(location.cancellations, 1);
      expect(controller.state.session!.phase, CardioRecordingPhase.paused);
      expect(
        (await store.route(id, ownerUserId: 'alice').toList()).single,
        hasLength(1),
      );
      await controller.resume();
      expect(location.subscriptions, 2);
      expect(
        controller.state.accuracyMeters,
        isNull,
        reason:
            'Resuming must wait for a new fix instead of displaying old accuracy.',
      );
      await controller.finish();
      expect(location.cancellations, 2);
      expect(
        (await store.read(id, ownerUserId: 'alice'))!.session.phase,
        CardioRecordingPhase.finished,
      );
      expect(controller.state.session!.pauses.single.reason, 'manual');
      expect(
        controller.state.session!.pauses.single.endMilliseconds,
        isNotNull,
      );
      controller.releaseFinished();
      expect(controller.state.session, isNull);
      controller.dispose();
    },
  );

  test(
    'restart recovery is interrupted and never silently requests location',
    () async {
      final session = CardioRecordingSession(
        id: 'saved',
        ownerUserId: 'alice',
        sport: CardioSport.running,
        startedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        phase: CardioRecordingPhase.recording,
        elapsedMilliseconds: 10000,
        activeMilliseconds: 10000,
      );
      await store.checkpoint(session, expectedRevision: 0, batchId: 'initial');
      await controller.restore('saved', chinese: true);
      expect(controller.state.session!.phase, CardioRecordingPhase.interrupted);
      expect(controller.state.session!.activeMilliseconds, 10000);
      expect(
        controller.state.session!.elapsedMilliseconds,
        greaterThanOrEqualTo(120000),
      );
      expect(location.requests, 0);
      expect(location.subscriptions, 0);
      final recoveredElapsed = controller.state.session!.elapsedMilliseconds;
      await Future<void>.delayed(const Duration(milliseconds: 25));
      await controller.resume();
      expect(location.requests, 1);
      expect(
        controller.state.session!.elapsedMilliseconds,
        greaterThan(recoveredElapsed),
      );
      expect(controller.state.session!.activeMilliseconds, 10000);
      expect(controller.state.session!.pauses.single.reason, 'interrupted');
      await controller.finish();
      controller.dispose();
    },
  );

  test(
    'cached live fixes do not enter the route or report current accuracy',
    () async {
      await _start(controller);
      location.stream.add(
        RoutePoint(
          latitude: 30,
          longitude: 120,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          accuracyMeters: 5,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.accuracyMeters, isNull);
      await controller.finish();
      expect(
        await store
            .route(controller.state.session!.id, ownerUserId: 'alice')
            .toList(),
        isEmpty,
      );
      expect(controller.state.session!.distanceMeters, 0);
      controller.dispose();
    },
  );

  test(
    'account disposal while requesting permission cannot start tracking',
    () async {
      location.permission = Completer<void>();
      final starting = _start(controller);
      while (location.requests == 0) {
        await Future<void>.delayed(Duration.zero);
      }
      controller.dispose();
      location.permission!.complete();
      await starting;
      expect(location.subscriptions, 0);
      expect(await store.list(ownerUserId: 'alice'), isEmpty);
    },
  );

  test('rapid duplicate starts create one local activity', () async {
    await Future.wait([_start(controller), _start(controller)]);
    expect(await store.list(ownerUserId: 'alice'), hasLength(1));
    expect(location.requests, 2);
    expect(location.subscriptions, 1);
    await controller.finish();
    controller.dispose();
  });

  test('finished unsaved activity survives detach and recovery', () async {
    await _start(controller);
    await controller.finish();
    final id = controller.state.session!.id;
    controller.releaseFinished();
    expect(controller.state.session, isNull);
    expect((await store.list(ownerUserId: 'alice')).single.session.id, id);
    final subscriptions = location.subscriptions;
    await controller.restore(id, chinese: true);
    expect(controller.state.session!.phase, CardioRecordingPhase.finished);
    expect(location.subscriptions, subscriptions);
    controller.dispose();
  });

  test(
    'location error pauses and persists instead of inventing a route',
    () async {
      await _start(controller);
      location.stream.addError(StateError('location revoked'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(controller.state.errorCode, 'location_interrupted');
      expect(controller.state.session!.phase, CardioRecordingPhase.interrupted);
      expect(controller.state.session!.distanceMeters, 0);
      await controller.finish();
      controller.dispose();
    },
  );

  test(
    'preparation rejects stale and inaccurate fixes without creating a session',
    () async {
      location.automaticPreparation = false;
      await controller.prepare(chinese: true);
      expect(controller.state.preparingLocation, isTrue);
      for (final point in [
        RoutePoint(
          latitude: 30,
          longitude: 120,
          timestamp: DateTime.now(),
          accuracyMeters: 100,
        ),
        RoutePoint(
          latitude: 30,
          longitude: 120,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          accuracyMeters: 5,
        ),
      ]) {
        location.preparation.add(point);
        await Future<void>.delayed(Duration.zero);
        expect(controller.state.locationReady, isFalse);
      }
      expect(await store.list(ownerUserId: 'alice'), isEmpty);
      location.preparation.add(
        RoutePoint(
          latitude: 30,
          longitude: 120,
          timestamp: DateTime.now(),
          accuracyMeters: 5,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.locationReady, isTrue);
      expect(controller.state.session, isNull);
      expect(controller.state.busy, isFalse);
      expect(location.preparation.hasListener, isFalse);
      expect(location.subscriptions, 0);
      controller.dispose();
    },
  );

  test(
    'permission-dialog inactivity keeps preparation; backgrounding cancels it',
    () async {
      location.automaticPreparation = false;
      await controller.prepare(chinese: true);
      controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
      expect(controller.state.preparingLocation, isTrue);
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.preparingLocation, isFalse);
      expect(location.preparation.hasListener, isFalse);
      expect(await store.list(ownerUserId: 'alice'), isEmpty);
      controller.dispose();
    },
  );

  test(
    'cancel preparation ignores late permission and never starts location',
    () async {
      location.permission = Completer<void>();
      final preparing = controller.prepare(chinese: true);
      controller.cancelPreparation();
      location.permission!.complete();
      await preparing;
      expect(controller.state.busy, isFalse);
      expect(controller.state.locationReady, isFalse);
      expect(location.preparation.hasListener, isFalse);
      expect(await store.list(ownerUserId: 'alice'), isEmpty);
      controller.dispose();
    },
  );

  test(
    'outdoor start requires a prepared fix; indoor timer needs no location',
    () async {
      await controller.start(
        sport: CardioSport.running,
        activityTypeId: 'cardio:running',
        activityName: '跑步',
        chinese: true,
      );
      expect(controller.state.errorCode, 'location_prepare_required');
      expect(location.requests, 0);
      expect(await store.list(ownerUserId: 'alice'), isEmpty);
      await controller.start(
        sport: CardioSport.indoor,
        activityTypeId: 'cardio:rowing',
        activityName: '划船',
        chinese: true,
      );
      expect(controller.state.session!.sport, CardioSport.indoor);
      expect(location.requests, 0);
      await controller.finish();
      controller.dispose();
    },
  );
}

class _ManualClock extends Stopwatch {
  int milliseconds = 0;
  bool running = false;
  @override
  int get elapsedMilliseconds => milliseconds;
  @override
  bool get isRunning => running;
  @override
  void reset() {
    milliseconds = 0;
  }

  @override
  void start() {
    running = true;
  }

  @override
  void stop() {
    running = false;
  }
}

class _DeniedNotification extends CardioBackgroundSupport {
  @override
  Future<CardioBackgroundStatus?> status({
    bool requestNotification = false,
  }) async => const CardioBackgroundStatus(
    notificationsEnabled: false,
    batteryUnrestricted: false,
    powerSaveMode: true,
  );
}

Future<void> _start(CardioRecordingController controller) async {
  await controller.prepare(chinese: true);
  await Future<void>.delayed(Duration.zero);
  await controller.start(
    sport: CardioSport.running,
    activityTypeId: 'cardio:running',
    activityName: '跑步',
    chinese: true,
  );
}

class _Location implements CardioLocationSource {
  int requests = 0, subscriptions = 0, cancellations = 0;
  Completer<void>? permission;
  bool automaticPreparation = true;
  final preparation = StreamController<RoutePoint>.broadcast();
  late final stream = StreamController<RoutePoint>.broadcast(
    onListen: () => subscriptions++,
    onCancel: () => cancellations++,
  );
  @override
  bool get supportsTracking => true;
  @override
  Future<void> requestPermission() async {
    requests++;
    await permission?.future;
  }

  @override
  Stream<RoutePoint> positions({
    required bool chinese,
    bool preparing = false,
  }) => preparing
      ? automaticPreparation
            ? Stream.value(
                RoutePoint(
                  latitude: 30,
                  longitude: 120,
                  timestamp: DateTime.now(),
                  accuracyMeters: 5,
                ),
              )
            : preparation.stream
      : stream.stream;
}
