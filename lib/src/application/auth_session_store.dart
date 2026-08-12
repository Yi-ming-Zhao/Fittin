import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedAuthUser {
  const CachedAuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.isAnonymous = false,
  });

  final String id;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
}

abstract class AuthSessionStore {
  Future<String?> loadAccessToken();

  Future<void> saveAccessToken(String token);

  Future<CachedAuthUser?> loadCachedUser();

  Future<void> saveCachedUser(CachedAuthUser user);

  Future<void> clear();
}

class InMemoryAuthSessionStore implements AuthSessionStore {
  String? _token;
  CachedAuthUser? _user;

  @override
  Future<void> clear() async {
    _token = null;
    _user = null;
  }

  @override
  Future<String?> loadAccessToken() async => _token;

  @override
  Future<CachedAuthUser?> loadCachedUser() async => _user;

  @override
  Future<void> saveAccessToken(String token) async {
    _token = token;
  }

  @override
  Future<void> saveCachedUser(CachedAuthUser user) async {
    _user = user;
  }
}

class SharedPreferencesAuthSessionStore implements AuthSessionStore {
  SharedPreferencesAuthSessionStore(this._preferences);

  static const _accessTokenKey = 'fittin.auth.accessToken';
  static const _userIdKey = 'fittin.auth.userId';
  static const _userEmailKey = 'fittin.auth.userEmail';
  static const _userDisplayNameKey = 'fittin.auth.userDisplayName';
  static const _userAnonymousKey = 'fittin.auth.userAnonymous';

  final SharedPreferences _preferences;

  @override
  Future<void> clear() async {
    await _preferences.remove(_accessTokenKey);
    await _preferences.remove(_userIdKey);
    await _preferences.remove(_userEmailKey);
    await _preferences.remove(_userDisplayNameKey);
    await _preferences.remove(_userAnonymousKey);
  }

  @override
  Future<String?> loadAccessToken() async {
    return _preferences.getString(_accessTokenKey);
  }

  @override
  Future<CachedAuthUser?> loadCachedUser() async {
    final id = _preferences.getString(_userIdKey);
    if (id == null || id.isEmpty) {
      return null;
    }
    return CachedAuthUser(
      id: id,
      email: _preferences.getString(_userEmailKey),
      displayName: _preferences.getString(_userDisplayNameKey),
      isAnonymous: _preferences.getBool(_userAnonymousKey) ?? false,
    );
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await _preferences.setString(_accessTokenKey, token);
  }

  @override
  Future<void> saveCachedUser(CachedAuthUser user) async {
    await _preferences.setString(_userIdKey, user.id);
    await _saveNullableString(_userEmailKey, user.email);
    await _saveNullableString(_userDisplayNameKey, user.displayName);
    await _preferences.setBool(_userAnonymousKey, user.isAnonymous);
  }

  Future<void> _saveNullableString(String key, String? value) async {
    if (value == null) {
      await _preferences.remove(key);
    } else {
      await _preferences.setString(key, value);
    }
  }
}

class PlatformAuthSessionStore implements AuthSessionStore {
  PlatformAuthSessionStore(
    this._preferences, {
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'fittin.auth.accessToken';
  static const _userIdKey = 'fittin.auth.userId';
  static const _userEmailKey = 'fittin.auth.userEmail';
  static const _userDisplayNameKey = 'fittin.auth.userDisplayName';
  static const _userAnonymousKey = 'fittin.auth.userAnonymous';

  final SharedPreferences _preferences;
  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> clear() async {
    if (!kIsWeb) await _secureStorage.delete(key: _accessTokenKey);
    await _preferences.remove(_accessTokenKey);
    await _preferences.remove(_userIdKey);
    await _preferences.remove(_userEmailKey);
    await _preferences.remove(_userDisplayNameKey);
    await _preferences.remove(_userAnonymousKey);
  }

  @override
  Future<String?> loadAccessToken() async {
    if (kIsWeb) return _preferences.getString(_accessTokenKey);
    final secureToken = await _secureStorage.read(key: _accessTokenKey);
    if (secureToken != null && secureToken.isNotEmpty) return secureToken;
    final legacyToken = _preferences.getString(_accessTokenKey);
    if (legacyToken != null && legacyToken.isNotEmpty) {
      await _secureStorage.write(key: _accessTokenKey, value: legacyToken);
      await _preferences.remove(_accessTokenKey);
    }
    return legacyToken;
  }

  @override
  Future<CachedAuthUser?> loadCachedUser() async {
    final id = _preferences.getString(_userIdKey);
    if (id == null || id.isEmpty) return null;
    return CachedAuthUser(
      id: id,
      email: _preferences.getString(_userEmailKey),
      displayName: _preferences.getString(_userDisplayNameKey),
      isAnonymous: _preferences.getBool(_userAnonymousKey) ?? false,
    );
  }

  @override
  Future<void> saveAccessToken(String token) async {
    if (kIsWeb) {
      await _preferences.setString(_accessTokenKey, token);
      return;
    }
    await _secureStorage.write(key: _accessTokenKey, value: token);
    await _preferences.remove(_accessTokenKey);
  }

  @override
  Future<void> saveCachedUser(CachedAuthUser user) async {
    await _preferences.setString(_userIdKey, user.id);
    await _saveNullableString(_userEmailKey, user.email);
    await _saveNullableString(_userDisplayNameKey, user.displayName);
    await _preferences.setBool(_userAnonymousKey, user.isAnonymous);
  }

  Future<void> _saveNullableString(String key, String? value) async {
    if (value == null) {
      await _preferences.remove(key);
    } else {
      await _preferences.setString(key, value);
    }
  }
}

final authSessionStoreProvider = Provider<AuthSessionStore>((ref) {
  return InMemoryAuthSessionStore();
});
