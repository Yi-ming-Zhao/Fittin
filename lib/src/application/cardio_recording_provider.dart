import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/cardio_location_source.dart';
import '../data/cardio_background_support.dart';
import '../data/cardio_recording_store.dart';
import '../data/cardio_recording_store_native.dart';
import '../data/cardio_recording_store_web.dart';
import '../data/web_database_repository.dart';
import '../domain/models/cardio_recording.dart';
import 'active_session_provider.dart';
import 'auth_provider.dart';

final cardioRecordingStoreProvider = Provider<CardioRecordingStore>((ref) {
  final db = ref.watch(databaseRepositoryProvider);
  return CardioRecordingStore(
    db is WebDatabaseRepository
        ? WebCardioLocalDocuments(db.store)
        : IsarCardioLocalDocuments(db.isar!),
  );
});
final cardioLocationSourceProvider = Provider<CardioLocationSource>(
  (ref) => DeviceCardioLocationSource(),
);
final localCardioSessionsProvider = FutureProvider<List<StoredCardioSession>>(
  (ref) => ref
      .watch(cardioRecordingStoreProvider)
      .list(ownerUserId: ref.watch(currentUserIdProvider)),
);

final cardioRecordingProvider =
    StateNotifierProvider<CardioRecordingController, CardioRecordingView>((
      ref,
    ) {
      final controller = CardioRecordingController(
        store: ref.watch(cardioRecordingStoreProvider),
        location: ref.watch(cardioLocationSourceProvider),
        ownerUserId: ref.watch(currentUserIdProvider),
        onSaved: () => ref.invalidate(localCardioSessionsProvider),
      );
      return controller;
    });

class CardioRecordingView {
  const CardioRecordingView({
    this.session,
    this.accuracyMeters,
    this.currentSpeedMps,
    this.locationStale = false,
    this.errorCode,
    this.busy = false,
    this.preparingLocation = false,
    this.locationReady = false,
    this.backgroundStatus,
  });
  final CardioRecordingSession? session;
  final double? accuracyMeters;
  final double? currentSpeedMps;
  final bool locationStale;
  final String? errorCode;
  final bool busy;
  final bool preparingLocation;
  final bool locationReady;
  final CardioBackgroundStatus? backgroundStatus;
}

class _RecordingBatch {
  _RecordingBatch(this.session, this.points, this.id);
  final CardioRecordingSession session;
  final List<RoutePoint> points;
  final String id;
}

/// Lives above routes: navigating away never stops a workout. Account changes
/// dispose this controller, stop location and persist an interrupted checkpoint.
class CardioRecordingController extends StateNotifier<CardioRecordingView>
    with WidgetsBindingObserver {
  CardioRecordingController({
    required this.store,
    required this.location,
    required this.ownerUserId,
    required this.onSaved,
    CardioBackgroundSupport? backgroundSupport,
    Stopwatch? clock,
  }) : super(const CardioRecordingView()) {
    _backgroundSupport = backgroundSupport ?? CardioBackgroundSupport();
    _clock = clock ?? Stopwatch();
    WidgetsBinding.instance.addObserver(this);
  }
  final CardioRecordingStore store;
  final CardioLocationSource location;
  final String? ownerUserId;
  final void Function() onSaved;
  late final CardioBackgroundSupport _backgroundSupport;
  CardioBackgroundStatus? _backgroundStatus;
  bool _foreground = true;
  int _lastCheckpointClock = 0;

  Future<void> refreshBackgroundStatus() async {
    final status = await _backgroundSupport.status();
    if (_closed) return;
    if (status == null && _backgroundStatus == null) return;
    _backgroundStatus = status;
    _publish();
  }

  Future<bool> openBackgroundSettings() => _backgroundSupport.openSettings();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _foreground = true;
      _advance();
      _publish();
      unawaited(refreshBackgroundStatus());
    } else if ({
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.detached,
    }.contains(state)) {
      _foreground = false;
      if (!kIsWeb && _recorder != null) {
        _advance();
        unawaited(_flush());
      }
    }
    if ({
          AppLifecycleState.paused,
          AppLifecycleState.hidden,
          AppLifecycleState.detached,
        }.contains(state) &&
        _recorder == null) {
      // Permission dialogs may temporarily make the app inactive. Cancel only
      // when it actually leaves the foreground, not while asking for consent.
      cancelPreparation();
    }
    if (kIsWeb &&
        state != AppLifecycleState.resumed &&
        _recorder?.session.phase == CardioRecordingPhase.recording) {
      unawaited(interrupt());
    }
  }

  CardioRecorder? _recorder;
  StreamSubscription<RoutePoint>? _positions;
  Timer? _ticker;
  late final Stopwatch _clock;
  int _clockBase = 0, _revision = 0;
  bool _closed = false, _command = false;
  Future<bool>? _writing;
  _RecordingBatch? _retry;
  String? _error;
  double? _accuracy;
  int? _lastFixClock;
  bool _chinese = true;
  bool _preparing = false;
  int _preparationEpoch = 0;
  RoutePoint? _preparedFix;
  StreamSubscription<RoutePoint>? _preparationPositions;
  Timer? _preparationTimer;

  bool get _locationReady =>
      _preparedFix != null &&
      DateTime.now().difference(_preparedFix!.timestamp).inSeconds < 30;

  /// A short foreground-only fix, explicitly requested by the user. No session,
  /// route or clock exists until the user subsequently presses Start.
  Future<void> prepare({required bool chinese}) async {
    if (_closed || _command || _preparing || _recorder != null) return;
    cancelPreparation();
    final epoch = _preparationEpoch;
    _preparing = true;
    _error = null;
    _publish();
    bool current() => !_closed && epoch == _preparationEpoch;
    void fail(String code) {
      if (!current()) return;
      cancelPreparation();
      _error = code;
      _publish();
    }

    try {
      await location.requestPermission();
      if (!current()) return;
      _preparationTimer = Timer(
        const Duration(seconds: 30),
        () => fail('location_fix_timeout'),
      );
      _preparationPositions = location
          .positions(chinese: chinese, preparing: true)
          .listen(
            (point) {
              if (!current() || !_preparing) return;
              final age = DateTime.now().difference(point.timestamp);
              _accuracy = point.isValid ? point.accuracyMeters : null;
              if (point.isValid &&
                  point.accuracyMeters != null &&
                  point.accuracyMeters! <= 50 &&
                  !age.isNegative &&
                  age <= const Duration(seconds: 10)) {
                _preparedFix = point;
                _preparing = false;
                _preparationTimer?.cancel();
                unawaited(_preparationPositions?.cancel());
                _preparationPositions = null;
                _preparationTimer = Timer(
                  const Duration(seconds: 30),
                  cancelPreparation,
                );
              }
              _publish();
            },
            onError: (Object _) => fail('location_unavailable'),
            onDone: () {
              if (_preparing) fail('location_unavailable');
            },
          );
    } catch (error) {
      fail(
        error is CardioLocationException ? error.code : 'location_unavailable',
      );
    }
  }

  void cancelPreparation() {
    _preparationEpoch++;
    _preparing = false;
    _preparedFix = null;
    _preparationTimer?.cancel();
    _preparationTimer = null;
    unawaited(_preparationPositions?.cancel());
    _preparationPositions = null;
    if (_recorder == null) _accuracy = null;
    _publish();
  }

  void _publish() {
    if (_closed) return;
    state = CardioRecordingView(
      session: _recorder == null
          ? null
          : CardioRecordingSession.fromJson(_recorder!.session.toJson()),
      accuracyMeters: _accuracy,
      currentSpeedMps: _recorder?.currentSpeedMps,
      locationStale:
          _lastFixClock != null &&
          (_recorder?.session.elapsedMilliseconds ?? 0) - _lastFixClock! >
              15000,
      errorCode: _error,
      busy: _command || _preparing,
      preparingLocation: _preparing,
      locationReady: _locationReady,
      backgroundStatus: _backgroundStatus,
    );
  }

  Future<void> start({
    required CardioSport sport,
    required String activityTypeId,
    required String activityName,
    required bool chinese,
  }) async {
    if (_command || _preparing || _recorder != null || _closed) return;
    if (sport != CardioSport.indoor && !_locationReady) {
      _error = 'location_prepare_required';
      _publish();
      return;
    }
    _command = true;
    _error = null;
    _publish();
    try {
      final unfinished = (await store.list(
        ownerUserId: ownerUserId,
      )).where((s) => s.session.phase != CardioRecordingPhase.finished);
      if (unfinished.isNotEmpty) {
        throw const CardioLocationException('unfinished_recording');
      }
      if (_closed) return;
      if (sport != CardioSport.indoor) await location.requestPermission();
      if (_closed) return;
      if (sport != CardioSport.indoor) {
        _backgroundStatus = await _backgroundSupport.status(
          requestNotification: true,
        );
      }
      if (_closed) return;
      if (!_foreground) {
        throw const CardioLocationException('foreground_required');
      }
      if (sport != CardioSport.indoor && !_locationReady) {
        throw const CardioLocationException('location_prepare_required');
      }
      cancelPreparation();
      _chinese = chinese;
      _recorder = CardioRecorder(
        CardioRecordingSession(
          id: 'cardio-record:${const Uuid().v4()}',
          ownerUserId: ownerUserId,
          sport: sport,
          startedAt: DateTime.now(),
          activityTypeId: activityTypeId,
          activityName: activityName,
        ),
      )..start();
      if (!await _flush() || _closed) return;
      if (!_foreground) {
        _error = 'foreground_required';
        await interrupt();
        return;
      }
      _beginClock();
      _listen();
    } catch (error) {
      _error = error is CardioLocationException
          ? error.code
          : 'location_unavailable';
      if (_recorder != null) await interrupt();
    } finally {
      _command = false;
      _publish();
    }
  }

  Future<void> restore(String id, {required bool chinese}) async {
    if (_command || _recorder != null || _closed) return;
    _command = true;
    cancelPreparation();
    _publish();
    try {
      final saved = await store.read(id, ownerUserId: ownerUserId);
      if (_closed || saved == null) return;
      _chinese = chinese;
      _revision = saved.revision;
      _recorder = CardioRecorder(saved.session);
      if (saved.session.phase != CardioRecordingPhase.finished) {
        _recorder!.interrupt();
        // The missing interval is explicitly paused, never inferred as moving.
        final wallElapsed = DateTime.now()
            .difference(saved.session.startedAt)
            .inMilliseconds;
        if (wallElapsed > saved.session.elapsedMilliseconds) {
          _recorder!.advance(Duration(milliseconds: wallElapsed));
        }
        await _flush();
        if (!_closed) _beginClock();
      }
    } catch (_) {
      _error = 'storage_unavailable';
    } finally {
      _command = false;
      _publish();
    }
  }

  void _beginClock() {
    _clockBase = _recorder!.session.elapsedMilliseconds;
    _clock
      ..reset()
      ..start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _advance();
      _publish();
      _checkpointIfDue();
    });
  }

  void _checkpointIfDue() {
    final elapsed = _recorder?.session.elapsedMilliseconds ?? 0;
    if (elapsed - _lastCheckpointClock < 5000 || _writing != null) return;
    _lastCheckpointClock = elapsed;
    unawaited(_flush());
  }

  void _advance() {
    if (_clock.isRunning) {
      _recorder?.advance(
        Duration(milliseconds: _clockBase + _clock.elapsedMilliseconds),
      );
    }
  }

  void _listen() {
    if (_recorder!.session.sport == CardioSport.indoor || _closed) return;
    _accuracy = null;
    _lastFixClock = null;
    _positions = location
        .positions(chinese: _chinese)
        .listen(
          (point) {
            if (_closed) return;
            _advance();
            final age = DateTime.now().difference(point.timestamp);
            if (age.isNegative || age > const Duration(seconds: 10)) {
              // Some platform providers deliver a cached fix first. It must
              // not become a fresh location indicator or part of this route.
              _accuracy = null;
              _publish();
              return;
            }
            _accuracy = point.isValid ? point.accuracyMeters : null;
            if (point.isValid) {
              _lastFixClock = _recorder!.session.elapsedMilliseconds;
            }
            _recorder!.accept(point);
            // iOS may defer UI timers while locked. Location delivery is also
            // a persistence trigger; recording never depends on rendering.
            _checkpointIfDue();
            _publish();
          },
          onError: (Object _) {
            _error = 'location_interrupted';
            unawaited(interrupt());
          },
          onDone: () {
            if (!_closed &&
                _recorder?.session.phase == CardioRecordingPhase.recording) {
              _error = 'location_interrupted';
              unawaited(interrupt());
            }
          },
        );
  }

  Future<void> pause() async {
    if (_command || _recorder == null || _closed) return;
    _command = true;
    try {
      _advance();
      _recorder!.pause();
      await _cancelLocation();
      _publish();
      await flush();
    } finally {
      _command = false;
      _publish();
    }
  }

  Future<void> resume() async {
    if (_command ||
        _recorder == null ||
        _closed ||
        ![
          CardioRecordingPhase.paused,
          CardioRecordingPhase.interrupted,
        ].contains(_recorder!.session.phase)) {
      return;
    }
    _command = true;
    _publish();
    try {
      if (!await flush()) return;
      if (_closed) return;
      if (_recorder!.session.sport != CardioSport.indoor) {
        await location.requestPermission();
      }
      if (_closed) return;
      if (!_foreground) {
        throw const CardioLocationException('foreground_required');
      }
      if (!_clock.isRunning) {
        final wallElapsed = DateTime.now()
            .difference(_recorder!.session.startedAt)
            .inMilliseconds;
        _recorder!.advance(Duration(milliseconds: wallElapsed));
      }
      _advance();
      _recorder!.resume();
      _error = null;
      if (!await _flush()) return;
      if (_closed) return;
      if (!_foreground) {
        _error = 'foreground_required';
        await interrupt();
        return;
      }
      _beginClock();
      _listen();
    } catch (error) {
      _error = error is CardioLocationException
          ? error.code
          : 'location_unavailable';
      await interrupt();
    } finally {
      _command = false;
      _publish();
    }
  }

  Future<void> interrupt() async {
    if (_recorder == null) return;
    _advance();
    _recorder!.interrupt();
    _ticker?.cancel();
    _clock.stop();
    await _cancelLocation();
    _publish();
    await flush();
  }

  Future<void> _cancelLocation() async {
    final subscription = _positions;
    _positions = null;
    try {
      await subscription?.cancel();
    } catch (_) {
      _error ??= 'location_interrupted';
    }
  }

  Future<void> finish() async {
    if (_command || _recorder == null || _closed) return;
    _command = true;
    try {
      _advance();
      _recorder!.finish();
      _ticker?.cancel();
      _clock.stop();
      await _cancelLocation();
      await flush();
    } finally {
      _command = false;
      _publish();
    }
  }

  void lap() {
    if (_recorder == null || _command) return;
    _advance();
    _recorder!.lap();
    _publish();
    unawaited(_flush());
  }

  void setAutoPause(bool enabled) {
    if (_recorder == null) return;
    _recorder!.session.autoPauseEnabled = enabled;
    // Resume automatic pauses explicitly when the feature is turned off.
    if (!enabled && _recorder!.session.autoPaused) {
      _advance();
      _recorder!.pause();
      _recorder!.resume();
    }
    _publish();
  }

  Future<bool> flush() async {
    final retrying = _retry != null;
    if (!await _flush()) return false;
    return retrying ? _flush() : true;
  }

  void releaseFinished() {
    if (_command ||
        _writing != null ||
        _retry != null ||
        _recorder?.session.phase != CardioRecordingPhase.finished) {
      return;
    }
    _recorder = null;
    _revision = 0;
    _error = null;
    _accuracy = null;
    _lastFixClock = null;
    _lastCheckpointClock = 0;
    _publish();
  }

  Future<bool> _flush() async {
    final pending = _writing;
    if (pending != null) {
      if (!await pending) return false;
      return _flush();
    }
    if (_recorder == null) return true;
    final batch =
        _retry ??
        _RecordingBatch(
          CardioRecordingSession.fromJson(_recorder!.session.toJson()),
          _recorder!.drainPoints(),
          const Uuid().v4(),
        );
    final completer = Completer<bool>();
    _writing = completer.future;
    var success = false;
    try {
      final saved = await store.checkpoint(
        batch.session,
        expectedRevision: _revision,
        batchId: batch.id,
        points: batch.points,
      );
      _revision = saved.revision;
      _retry = null;
      success = true;
      if (!_closed) onSaved();
    } catch (error) {
      _retry = batch;
      _error = error is CardioRecordingConflict
          ? 'recording_conflict'
          : 'storage_unavailable';
      _advance();
      _recorder!.interrupt();
      _clock.stop();
      _ticker?.cancel();
      await _cancelLocation();
      _publish();
    } finally {
      _writing = null;
      completer.complete(success);
    }
    return success;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _advance();
    _closed = true;
    cancelPreparation();
    _ticker?.cancel();
    _clock.stop();
    unawaited(_positions?.cancel());
    if (_recorder != null &&
        _recorder!.session.phase != CardioRecordingPhase.finished) {
      _recorder!.interrupt();
      unawaited(_flush());
    }
    super.dispose();
  }
}
