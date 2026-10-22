import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CardioBackgroundStatus {
  const CardioBackgroundStatus({
    required this.notificationsEnabled,
    required this.batteryUnrestricted,
    required this.powerSaveMode,
  });
  final bool notificationsEnabled, batteryUnrestricted, powerSaveMode;
}

/// No background-location grant or battery exemption is requested silently.
class CardioBackgroundSupport {
  static const channel = MethodChannel('fittin/cardio-background');

  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<CardioBackgroundStatus?> status({
    bool requestNotification = false,
  }) async {
    if (!supported) return null;
    try {
      final value = await channel.invokeMapMethod<String, dynamic>(
        requestNotification ? 'requestNotification' : 'status',
      );
      if (value == null) return null;
      return CardioBackgroundStatus(
        notificationsEnabled: value['notificationsEnabled'] == true,
        batteryUnrestricted: value['batteryUnrestricted'] == true,
        powerSaveMode: value['powerSaveMode'] == true,
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<bool> openSettings() async {
    if (!supported) return false;
    try {
      return await channel.invokeMethod<bool>('openSettings') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
