import 'dart:math' as math;

enum CardioRecordingPhase { ready, recording, paused, interrupted, finished }

enum CardioSport { running, walking, cycling, hiking, indoor }

class CardioPause {
  CardioPause(this.startMilliseconds, this.reason, [this.endMilliseconds]);
  final int startMilliseconds;
  final String reason;
  int? endMilliseconds;
  Map<String, dynamic> toJson() => {
    'start': startMilliseconds,
    'end': endMilliseconds,
    'reason': reason,
  };
  factory CardioPause.fromJson(Map<String, dynamic> value) => CardioPause(
    value['start'] as int,
    value['reason'] as String,
    value['end'] as int?,
  );
}

/// A measured position, never a guessed point in a missing route segment.
class RoutePoint {
  const RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracyMeters,
    this.altitudeMeters,
    this.segment = 0,
    this.coordinateSystem = 'WGS84',
  });
  final double latitude, longitude;
  // Import formats often omit accuracy. Missing is not a zero-error GPS fix.
  final double? accuracyMeters, altitudeMeters;
  final DateTime timestamp;
  final int segment;
  final String coordinateSystem;

  bool get isValid =>
      latitude.isFinite &&
      longitude.isFinite &&
      latitude.abs() <= 90 &&
      longitude.abs() <= 180 &&
      (accuracyMeters == null ||
          (accuracyMeters!.isFinite && accuracyMeters! >= 0)) &&
      (altitudeMeters == null || altitudeMeters!.isFinite) &&
      coordinateSystem == 'WGS84';

  RoutePoint inSegment(int value) => RoutePoint(
    latitude: latitude,
    longitude: longitude,
    timestamp: timestamp,
    accuracyMeters: accuracyMeters,
    altitudeMeters: altitudeMeters,
    segment: value,
    coordinateSystem: coordinateSystem,
  );

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'accuracyMeters': accuracyMeters,
    'altitudeMeters': altitudeMeters,
    'segment': segment,
    'coordinateSystem': coordinateSystem,
  };
  factory RoutePoint.fromJson(Map<String, dynamic> j) => RoutePoint(
    latitude: (j['latitude'] as num).toDouble(),
    longitude: (j['longitude'] as num).toDouble(),
    timestamp: DateTime.parse(j['timestamp'] as String),
    accuracyMeters: (j['accuracyMeters'] as num?)?.toDouble(),
    altitudeMeters: (j['altitudeMeters'] as num?)?.toDouble(),
    segment: j['segment'] as int? ?? 0,
    coordinateSystem: j['coordinateSystem'] as String? ?? 'WGS84',
  );
}

class CardioLap {
  const CardioLap({
    required this.distanceMeters,
    required this.activeMilliseconds,
    required this.endDistanceMeters,
    required this.automatic,
  });
  final double distanceMeters, endDistanceMeters;
  final int activeMilliseconds;
  final bool automatic;
  double? get paceSecondsPerKm =>
      distanceMeters > 0 ? activeMilliseconds / distanceMeters : null;
  Map<String, dynamic> toJson() => {
    'distanceMeters': distanceMeters,
    'activeMilliseconds': activeMilliseconds,
    'endDistanceMeters': endDistanceMeters,
    'automatic': automatic,
  };
  factory CardioLap.fromJson(Map<String, dynamic> j) => CardioLap(
    distanceMeters: (j['distanceMeters'] as num).toDouble(),
    activeMilliseconds: j['activeMilliseconds'] as int,
    endDistanceMeters: (j['endDistanceMeters'] as num).toDouble(),
    automatic: j['automatic'] == true,
  );
}

/// Owner-scoped local checkpoint. Raw route points are drained separately so
/// recording persistence does not rewrite the entire route on every fix.
class CardioRecordingSession {
  CardioRecordingSession({
    required this.id,
    required this.ownerUserId,
    required this.sport,
    required this.startedAt,
    this.activityTypeId = '',
    this.activityName = '',
    this.phase = CardioRecordingPhase.ready,
    this.elapsedMilliseconds = 0,
    this.activeMilliseconds = 0,
    this.distanceMeters = 0,
    this.segment = 0,
    List<CardioLap> laps = const [],
    List<CardioPause> pauses = const [],
    this.autoPauseEnabled = false,
    this.autoPaused = false,
    this.lapStartMeters = 0,
    this.lapStartMilliseconds = 0,
    this.nextSplitMeters = 1000,
  }) : laps = List.of(laps),
       pauses = List.of(pauses);
  final String id;
  final String? ownerUserId;
  final CardioSport sport;
  final DateTime startedAt;
  final String activityTypeId, activityName;
  CardioRecordingPhase phase;
  int elapsedMilliseconds, activeMilliseconds, segment;
  double distanceMeters, lapStartMeters, nextSplitMeters;
  int lapStartMilliseconds;
  bool autoPauseEnabled, autoPaused;
  final List<CardioLap> laps;
  final List<CardioPause> pauses;

  void validate() {
    if (id.isEmpty ||
        elapsedMilliseconds < 0 ||
        activeMilliseconds < 0 ||
        activeMilliseconds > elapsedMilliseconds ||
        segment < 0 ||
        !distanceMeters.isFinite ||
        distanceMeters < 0 ||
        !lapStartMeters.isFinite ||
        lapStartMeters < 0 ||
        lapStartMeters > distanceMeters ||
        lapStartMilliseconds < 0 ||
        lapStartMilliseconds > activeMilliseconds ||
        !nextSplitMeters.isFinite ||
        nextSplitMeters <= 0 ||
        laps.any(
          (lap) =>
              !lap.distanceMeters.isFinite ||
              lap.distanceMeters <= 0 ||
              lap.activeMilliseconds <= 0 ||
              !lap.endDistanceMeters.isFinite ||
              lap.endDistanceMeters < lap.distanceMeters ||
              lap.endDistanceMeters > distanceMeters + 0.5,
        )) {
      throw const FormatException('Invalid cardio checkpoint.');
    }
    var previousEnd = 0;
    for (var i = 0; i < pauses.length; i++) {
      final pause = pauses[i];
      if (pause.startMilliseconds < previousEnd ||
          pause.startMilliseconds > elapsedMilliseconds ||
          !{'manual', 'automatic', 'interrupted'}.contains(pause.reason) ||
          (pause.endMilliseconds == null && i != pauses.length - 1) ||
          (pause.endMilliseconds != null &&
              (pause.endMilliseconds! < pause.startMilliseconds ||
                  pause.endMilliseconds! > elapsedMilliseconds))) {
        throw const FormatException('Invalid cardio pause interval.');
      }
      previousEnd = pause.endMilliseconds ?? elapsedMilliseconds;
    }
  }

  double? get averageSpeedMps => activeMilliseconds > 0 && distanceMeters > 0
      ? distanceMeters * 1000 / activeMilliseconds
      : null;
  double? get paceSecondsPerKm =>
      distanceMeters > 0 ? activeMilliseconds / distanceMeters : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerUserId': ownerUserId,
    'sport': sport.name,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'activityTypeId': activityTypeId,
    'activityName': activityName,
    'phase': phase.name,
    'elapsedMilliseconds': elapsedMilliseconds,
    'activeMilliseconds': activeMilliseconds,
    'distanceMeters': distanceMeters,
    'segment': segment,
    'laps': laps.map((lap) => lap.toJson()).toList(),
    'pauses': pauses.map((pause) => pause.toJson()).toList(),
    'autoPauseEnabled': autoPauseEnabled,
    'autoPaused': autoPaused,
    'lapStartMeters': lapStartMeters,
    'lapStartMilliseconds': lapStartMilliseconds,
    'nextSplitMeters': nextSplitMeters,
  };
  factory CardioRecordingSession.fromJson(Map<String, dynamic> j) =>
      CardioRecordingSession(
        id: j['id'] as String,
        ownerUserId: j['ownerUserId'] as String?,
        sport: CardioSport.values.byName(j['sport'] as String),
        startedAt: DateTime.parse(j['startedAt'] as String),
        activityTypeId: j['activityTypeId'] as String? ?? '',
        activityName: j['activityName'] as String? ?? '',
        phase: CardioRecordingPhase.values.byName(j['phase'] as String),
        elapsedMilliseconds: j['elapsedMilliseconds'] as int,
        activeMilliseconds: j['activeMilliseconds'] as int,
        distanceMeters: (j['distanceMeters'] as num).toDouble(),
        segment: j['segment'] as int,
        laps: (j['laps'] as List)
            .map((l) => CardioLap.fromJson(Map<String, dynamic>.from(l as Map)))
            .toList(),
        pauses: (j['pauses'] as List? ?? [])
            .map(
              (p) => CardioPause.fromJson(Map<String, dynamic>.from(p as Map)),
            )
            .toList(),
        autoPauseEnabled: j['autoPauseEnabled'] == true,
        autoPaused: j['autoPaused'] == true,
        lapStartMeters: (j['lapStartMeters'] as num).toDouble(),
        lapStartMilliseconds: j['lapStartMilliseconds'] as int,
        nextSplitMeters: (j['nextSplitMeters'] as num).toDouble(),
      );
}

class CardioRecorder {
  CardioRecorder(this.session);
  final CardioRecordingSession session;
  RoutePoint? _anchor;
  RoutePoint? _lastFix;
  int? _stillSince;
  int? _lastMovementClock;
  final List<({DateTime end, double meters, double seconds})> _speedWindow = [];
  final List<RoutePoint> _pendingPoints = [];

  /// A short measured window, not the activity average. A lost fix, pause or
  /// restored session has no current speed rather than an invented zero.
  double? get currentSpeedMps {
    if (session.phase != CardioRecordingPhase.recording ||
        session.autoPaused ||
        _lastMovementClock == null ||
        session.elapsedMilliseconds - _lastMovementClock! > 10000 ||
        _speedWindow.isEmpty) {
      return null;
    }
    final meters = _speedWindow.fold(0.0, (sum, part) => sum + part.meters);
    final seconds = _speedWindow.fold(0.0, (sum, part) => sum + part.seconds);
    return seconds > 0 ? meters / seconds : null;
  }

  List<RoutePoint> drainPoints() {
    final result = List<RoutePoint>.of(_pendingPoints);
    _pendingPoints.clear();
    return result;
  }

  /// Caller supplies a monotonic session clock, never a wall-clock delta.
  void advance(Duration elapsed) {
    final next = elapsed.inMilliseconds;
    if (next < session.elapsedMilliseconds) {
      throw ArgumentError('Session clock must be monotonic.');
    }
    if (session.phase == CardioRecordingPhase.finished ||
        session.phase == CardioRecordingPhase.ready) {
      return;
    }
    if (session.phase == CardioRecordingPhase.recording &&
        !session.autoPaused) {
      session.activeMilliseconds += next - session.elapsedMilliseconds;
    }
    session.elapsedMilliseconds = next;
  }

  void start() {
    if (session.phase != CardioRecordingPhase.ready) {
      throw StateError('Session already started.');
    }
    session.phase = CardioRecordingPhase.recording;
  }

  void pause() {
    if (session.phase != CardioRecordingPhase.recording) return;
    session.phase = CardioRecordingPhase.paused;
    _beginPause('manual');
    _breakSegment();
  }

  void resume() {
    if (session.phase != CardioRecordingPhase.paused &&
        session.phase != CardioRecordingPhase.interrupted) {
      return;
    }
    session.phase = CardioRecordingPhase.recording;
    _endPause();
    session.autoPaused = false;
    _stillSince = null;
    _breakSegment();
  }

  void interrupt() {
    if (session.phase == CardioRecordingPhase.finished) return;
    session.phase = CardioRecordingPhase.interrupted;
    _beginPause('interrupted');
    _breakSegment();
  }

  void finish() {
    if (session.phase == CardioRecordingPhase.ready ||
        session.phase == CardioRecordingPhase.finished) {
      return;
    }
    if (session.distanceMeters > session.lapStartMeters) lap();
    session.phase = CardioRecordingPhase.finished;
    _endPause();
    _breakSegment();
  }

  void _breakSegment() {
    _anchor = null;
    _stillSince = null;
    _lastMovementClock = null;
    _speedWindow.clear();
    session.segment++;
  }

  void _beginPause(String reason) {
    if (session.pauses.isNotEmpty &&
        session.pauses.last.endMilliseconds == null) {
      return;
    }
    session.pauses.add(CardioPause(session.elapsedMilliseconds, reason));
  }

  void _endPause() {
    if (session.pauses.isNotEmpty &&
        session.pauses.last.endMilliseconds == null) {
      session.pauses.last.endMilliseconds = session.elapsedMilliseconds;
    }
  }

  bool accept(RoutePoint raw) {
    if (session.phase != CardioRecordingPhase.recording ||
        session.sport == CardioSport.indoor) {
      return false;
    }
    if (!raw.isValid ||
        raw.accuracyMeters == null ||
        raw.accuracyMeters! > 50) {
      _breakSegment();
      return false;
    }
    final lastFix = _lastFix;
    if (lastFix != null && !raw.timestamp.isAfter(lastFix.timestamp)) {
      return false;
    }
    // The displacement anchor deliberately stays put while jitter is ignored.
    // Reception continuity must instead use the last valid fix, otherwise a
    // stationary phone is treated as disconnected every fifteen seconds.
    final receptionGap = lastFix == null
        ? null
        : raw.timestamp.difference(lastFix.timestamp);
    final fixSeconds = receptionGap == null
        ? 0.0
        : receptionGap.inMicroseconds / 1000000;
    final fixMeters = lastFix == null ? 0.0 : routeDistanceMeters(lastFix, raw);
    _lastFix = raw;
    final previous = _anchor;
    if (previous == null) {
      _anchor = raw;
      _pendingPoints.add(raw.inSegment(session.segment));
      return true;
    }
    final meters = routeDistanceMeters(previous, raw);
    final anchorSeconds =
        raw.timestamp.difference(previous.timestamp).inMicroseconds / 1000000;
    final maximumSpeed = switch (session.sport) {
      CardioSport.cycling => 35.0,
      CardioSport.running => 12.0,
      CardioSport.walking => 5.0,
      CardioSport.hiking => 7.0,
      CardioSport.indoor => 0.0,
    };
    if ((receptionGap != null && receptionGap > const Duration(seconds: 15)) ||
        (fixSeconds > 0 && fixMeters / fixSeconds > maximumSpeed)) {
      _breakSegment();
      _anchor = raw;
      _pendingPoints.add(raw.inSegment(session.segment));
      return true;
    }
    if (meters < 3) {
      _stillSince ??= session.elapsedMilliseconds;
      if (session.autoPauseEnabled &&
          session.elapsedMilliseconds - _stillSince! >= 10000) {
        session.autoPaused = true;
        _beginPause('automatic');
      }
      return false;
    }
    final wasStationary =
        _stillSince != null &&
        session.elapsedMilliseconds - _stillSince! >= 10000;
    _stillSince = null;
    if (session.autoPaused) {
      session.autoPaused = false;
      _endPause();
      _breakSegment();
    } else {
      _lastMovementClock = session.elapsedMilliseconds;
      _speedWindow.removeWhere(
        (part) => raw.timestamp.difference(part.end).inMilliseconds > 10000,
      );
      // A stationary displacement anchor may be minutes old. It is useful for
      // accumulating small movements, not for the current measured speed.
      _speedWindow.add((
        end: raw.timestamp,
        meters: fixMeters,
        seconds: fixSeconds,
      ));
      final before = session.distanceMeters;
      session.distanceMeters += meters;
      if (session.distanceMeters >= session.nextSplitMeters) {
        final fraction = (session.nextSplitMeters - before) / meters;
        // Normal sub-threshold motion spans several fixes; retain its time.
        // After a detected stop, crossing occurs in the resumed interval,
        // not somewhere inside the preceding stationary minutes.
        final splitSeconds = wasStationary ? fixSeconds : anchorSeconds;
        final endTime =
            session.activeMilliseconds -
            ((1 - fraction) * splitSeconds * 1000).round();
        _addLap(
          session.nextSplitMeters,
          endTime.clamp(
            session.lapStartMilliseconds,
            session.activeMilliseconds,
          ),
          true,
        );
        session.nextSplitMeters += 1000;
      }
    }
    _anchor = raw;
    _pendingPoints.add(raw.inSegment(session.segment));
    return true;
  }

  void lap() =>
      _addLap(session.distanceMeters, session.activeMilliseconds, false);
  void _addLap(double distance, int time, bool automatic) {
    if (distance <= session.lapStartMeters ||
        time <= session.lapStartMilliseconds) {
      return;
    }
    session.laps.add(
      CardioLap(
        distanceMeters: distance - session.lapStartMeters,
        activeMilliseconds: time - session.lapStartMilliseconds,
        endDistanceMeters: distance,
        automatic: automatic,
      ),
    );
    session.lapStartMeters = distance;
    session.lapStartMilliseconds = time;
  }
}

double routeDistanceMeters(RoutePoint a, RoutePoint b) {
  const rad = math.pi / 180;
  final lat = (b.latitude - a.latitude) * rad;
  final lon = (b.longitude - a.longitude) * rad;
  final h =
      math.pow(math.sin(lat / 2), 2) +
      math.cos(a.latitude * rad) *
          math.cos(b.latitude * rad) *
          math.pow(math.sin(lon / 2), 2);
  return 6371008.8 * 2 * math.asin(math.sqrt(h.clamp(0, 1)));
}
