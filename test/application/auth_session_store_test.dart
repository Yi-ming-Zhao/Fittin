import 'package:fittin_v2/src/application/auth_session_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'native store migrates access and protects refresh credentials',
    () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      SharedPreferences.setMockInitialValues({
        'fittin.auth.accessToken': 'legacy-access',
      });
      final preferences = await SharedPreferences.getInstance();
      const secureStorage = FlutterSecureStorage();
      final store = PlatformAuthSessionStore(
        preferences,
        secureStorage: secureStorage,
      );

      expect(await store.loadAccessToken(), 'legacy-access');
      expect(preferences.getString('fittin.auth.accessToken'), isNull);
      expect(
        await secureStorage.read(key: 'fittin.auth.accessToken'),
        'legacy-access',
      );

      await store.saveRefreshToken('native-refresh-secret');
      expect(preferences.getString('fittin.auth.refreshToken'), isNull);
      expect(
        await secureStorage.read(key: 'fittin.auth.refreshToken'),
        'native-refresh-secret',
      );
    },
  );

  test('native session clear preserves its device identity', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    SharedPreferences.setMockInitialValues(const {});
    final preferences = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    final store = PlatformAuthSessionStore(
      preferences,
      secureStorage: secureStorage,
    );
    final deviceId = await store.loadOrCreateDeviceId();
    await store.saveAccessToken('access');
    await store.saveRefreshToken('refresh');
    await store.saveCachedUser(const CachedAuthUser(id: 'user-1'));

    await store.clear();

    expect(await store.loadAccessToken(), isNull);
    expect(await store.loadRefreshToken(), isNull);
    expect(await store.loadCachedUser(), isNull);
    expect(await store.loadOrCreateDeviceId(), deviceId);
  });
}
