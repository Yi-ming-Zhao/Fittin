import 'package:fittin_v2/src/data/cardio_background_support.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(CardioBackgroundSupport.channel, null);
  });
  test(
    'Android checks and requests notification only on explicit call',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final calls = <String>[];
      messenger.setMockMethodCallHandler(CardioBackgroundSupport.channel, (
        call,
      ) async {
        calls.add(call.method);
        return call.method == 'openSettings'
            ? true
            : {
                'notificationsEnabled': false,
                'batteryUnrestricted': true,
                'powerSaveMode': false,
              };
      });
      final support = CardioBackgroundSupport();
      expect((await support.status())!.notificationsEnabled, isFalse);
      expect(calls, ['status']);
      expect(
        (await support.status(requestNotification: true))!.batteryUnrestricted,
        isTrue,
      );
      expect(await support.openSettings(), isTrue);
      expect(calls, ['status', 'requestNotification', 'openSettings']);
    },
  );
  test('unsupported platforms never invoke native Android channel', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messenger.setMockMethodCallHandler(
      CardioBackgroundSupport.channel,
      (_) async => fail('unexpected channel'),
    );
    expect(
      await CardioBackgroundSupport().status(requestNotification: true),
      isNull,
    );
    expect(await CardioBackgroundSupport().openSettings(), isFalse);
  });
  test(
    'missing or failing native status remains unknown, never claims ready',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      messenger.setMockMethodCallHandler(
        CardioBackgroundSupport.channel,
        (_) async => throw PlatformException(code: 'unavailable'),
      );
      expect(await CardioBackgroundSupport().status(), isNull);
      expect(await CardioBackgroundSupport().openSettings(), isFalse);
    },
  );
}
