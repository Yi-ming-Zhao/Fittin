import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../domain/models/cardio_recording.dart';

class CardioLocationException implements Exception {
  const CardioLocationException(this.code);
  final String code;
}

abstract interface class CardioLocationSource {
  bool get supportsTracking;
  Future<void> requestPermission();
  Stream<RoutePoint> positions({required bool chinese, bool preparing = false});
}

class DeviceCardioLocationSource implements CardioLocationSource {
  @override
  bool get supportsTracking =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<void> requestPermission() async {
    if (!supportsTracking) throw const CardioLocationException('unsupported');
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const CardioLocationException('location_disabled');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const CardioLocationException('permission_denied');
    }
  }

  @override
  Stream<RoutePoint> positions({
    required bool chinese,
    bool preparing = false,
  }) {
    final LocationSettings settings;
    if (kIsWeb) {
      settings = WebSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        maximumAge: Duration.zero,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: preparing
            ? null
            : ForegroundNotificationConfig(
                notificationTitle: chinese
                    ? 'Fittin · 正在记录运动'
                    : 'Fittin · Recording activity',
                notificationText: chinese
                    ? '定位仅用于本次运动，返回应用可暂停或结束。'
                    : 'Location is used only for this activity. Open Fittin to pause or finish.',
                enableWakeLock: true,
              ),
      );
    } else {
      settings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.fitness,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: !preparing,
        allowBackgroundLocationUpdates: !preparing,
      );
    }
    return Geolocator.getPositionStream(locationSettings: settings).map(
      (p) => RoutePoint(
        latitude: p.latitude,
        longitude: p.longitude,
        timestamp: p.timestamp,
        accuracyMeters: p.accuracy,
        altitudeMeters: p.altitudeAccuracy > 0 ? p.altitude : null,
      ),
    );
  }
}
