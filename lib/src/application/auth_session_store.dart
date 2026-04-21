import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthSessionStore {
  Future<String?> loadAccessToken();

  Future<void> saveAccessToken(String token);

  Future<void> clear();
}

class InMemoryAuthSessionStore implements AuthSessionStore {
  String? _token;

  @override
  Future<void> clear() async {
    _token = null;
  }

  @override
  Future<String?> loadAccessToken() async => _token;

  @override
  Future<void> saveAccessToken(String token) async {
    _token = token;
  }
}

class SharedPreferencesAuthSessionStore implements AuthSessionStore {
  SharedPreferencesAuthSessionStore(this._preferences);

  static const _accessTokenKey = 'fittin.auth.accessToken';

  final SharedPreferences _preferences;

  @override
  Future<void> clear() async {
    await _preferences.remove(_accessTokenKey);
  }

  @override
  Future<String?> loadAccessToken() async {
    return _preferences.getString(_accessTokenKey);
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await _preferences.setString(_accessTokenKey, token);
  }
}

final authSessionStoreProvider = Provider<AuthSessionStore>((ref) {
  return InMemoryAuthSessionStore();
});
