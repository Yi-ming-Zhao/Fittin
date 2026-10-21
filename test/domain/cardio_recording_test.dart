import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/domain/models/cardio_recording.dart';

void main() {
  final start = DateTime.utc(2026, 10, 21);
  CardioRecorder recorder({
    CardioSport sport = CardioSport.running,
    bool autoPause = false,
  }) => CardioRecorder(
    CardioRecordingSession(
      id: 'run',
      ownerUserId: 'owner',
      sport: sport,
      startedAt: start,
      autoPauseEnabled: autoPause,
    ),
  )..start();
  RoutePoint point(int seconds, double meters, {double accuracy = 5}) =>
      RoutePoint(
        latitude: 0,
        longitude: meters / 111195.08,
        timestamp: start.add(Duration(seconds: seconds)),
        accuracyMeters: accuracy,
      );

  test('records measured distance, pace and kilometre splits', () {
    final r = recorder();
    for (var i = 0; i <= 110; i++) {
      r.advance(Duration(seconds: i * 5));
      r.accept(point(i * 5, i * 10));
    }
    expect(r.session.distanceMeters, closeTo(1100, .01));
    expect(r.session.paceSecondsPerKm, closeTo(500, .01));
    expect(r.session.laps.single.distanceMeters, 1000);
    expect(r.session.laps.single.automatic, isTrue);
    r.finish();
    expect(r.session.laps, hasLength(2));
    expect(r.session.phase, CardioRecordingPhase.finished);
    final elapsed = r.session.elapsedMilliseconds;
    r.advance(const Duration(hours: 2));
    expect(r.session.elapsedMilliseconds, elapsed);
  });

  test(
    'pause excludes time and displacement and creates a separate segment',
    () {
      final r = recorder();
      r.accept(point(0, 0));
      r.advance(const Duration(seconds: 5));
      r.accept(point(5, 10));
      r.pause();
      r.advance(const Duration(seconds: 100));
      expect(r.accept(point(100, 1000)), isFalse);
      r.resume();
      r.accept(point(100, 1000));
      r.advance(const Duration(seconds: 105));
      r.accept(point(105, 1010));
      expect(r.session.activeMilliseconds, 10000);
      expect(r.session.elapsedMilliseconds, 105000);
      expect(r.session.distanceMeters, closeTo(20, .01));
      expect(r.drainPoints().map((p) => p.segment).toSet(), hasLength(2));
      expect(r.drainPoints(), isEmpty);
    },
  );

  test('poor accuracy, jumps and gaps do not fabricate connected distance', () {
    final r = recorder();
    r.accept(point(0, 0));
    expect(r.accept(point(1, 50, accuracy: 100)), isFalse);
    r.accept(point(2, 200));
    r.accept(point(3, 10000));
    r.accept(point(50, 20000));
    expect(r.session.distanceMeters, 0);
    expect(
      r.drainPoints().map((p) => p.segment).toSet().length,
      greaterThan(1),
    );
  });

  test('stale and invalid positions never change totals', () {
    final r = recorder();
    r.accept(point(5, 0));
    expect(r.accept(point(4, 10)), isFalse);
    expect(
      r.accept(
        RoutePoint(
          latitude: double.nan,
          longitude: 0,
          timestamp: start,
          accuracyMeters: 5,
        ),
      ),
      isFalse,
    );
    expect(r.session.distanceMeters, 0);
  });

  test(
    'interrupted checkpoint restores paused without bridging lost movement',
    () {
      final r = recorder();
      r.accept(point(0, 0));
      r.advance(const Duration(seconds: 5));
      r.accept(point(5, 10));
      final restored = CardioRecorder(
        CardioRecordingSession.fromJson(r.session.toJson()),
      );
      restored.interrupt();
      restored.advance(const Duration(seconds: 300));
      restored.resume();
      restored.accept(point(300, 3000));
      expect(restored.session.activeMilliseconds, 5000);
      expect(restored.session.distanceMeters, closeTo(10, .01));
      expect(restored.session.ownerUserId, 'owner');
    },
  );

  test('indoor timer never invents distance or pace', () {
    final r = recorder(sport: CardioSport.indoor);
    r.advance(const Duration(minutes: 20));
    expect(r.accept(point(1200, 2000)), isFalse);
    expect(r.session.paceSecondsPerKm, isNull);
    expect(r.session.averageSpeedMps, isNull);
    expect(r.session.activeMilliseconds, 1200000);
  });

  test('optional auto pause preserves a separate resumed route segment', () {
    final r = recorder(autoPause: true);
    for (var i = 0; i <= 12; i++) {
      r.advance(Duration(seconds: i));
      r.accept(point(i, 0));
    }
    expect(r.session.autoPaused, isTrue);
    final active = r.session.activeMilliseconds;
    r.advance(const Duration(seconds: 13));
    r.accept(point(13, 10));
    expect(r.session.autoPaused, isFalse);
    expect(r.session.activeMilliseconds, active);
    expect(r.session.distanceMeters, 0);
  });

  test('monotonic clock rejects backwards time', () {
    final r = recorder();
    r.advance(const Duration(seconds: 10));
    expect(() => r.advance(const Duration(seconds: 9)), throwsArgumentError);
  });

  test(
    'current speed uses measured movement and clears on gaps and pauses',
    () {
      final r = recorder();
      expect(r.currentSpeedMps, isNull);
      r.accept(point(0, 0));
      r.advance(const Duration(seconds: 5));
      r.accept(point(5, 10));
      expect(r.currentSpeedMps, closeTo(2, .01));
      r.advance(const Duration(seconds: 16));
      expect(r.currentSpeedMps, isNull);
      r.accept(point(16, 32));
      expect(r.currentSpeedMps, closeTo(2, .01));
      r.pause();
      expect(r.currentSpeedMps, isNull);
      r.resume();
      r.accept(point(17, 34));
      expect(r.currentSpeedMps, isNull);
      r.advance(const Duration(seconds: 22));
      r.accept(point(22, 44));
      expect(r.currentSpeedMps, closeTo(2, .01));
      r.accept(point(23, 46, accuracy: 100));
      expect(r.currentSpeedMps, isNull);
    },
  );
}
