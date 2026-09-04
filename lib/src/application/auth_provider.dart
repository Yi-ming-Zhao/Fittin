import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:fittin_v2/src/application/auth_http_client.dart';
import 'package:fittin_v2/src/application/auth_session_store.dart';
import 'package:fittin_v2/src/application/supabase_bootstrap.dart';

const backendUnavailableMessage =
    'Service temporarily unavailable. Please try again. '
    'Your local training data is safe.';

class AuthUser {
  const AuthUser({
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

abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  Future<AuthUser?> currentUser();

  Future<String?> currentAccessToken();

  Future<String?> refreshAccessToken({String? failedAccessToken});

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> signUp({required String email, required String password});

  Future<void> signOut();
}

class BackendAuthRepository implements AuthRepository {
  BackendAuthRepository({
    required String baseUrl,
    required AuthSessionStore sessionStore,
    http.Client? httpClient,
  }) : _baseUrl = baseUrl,
       _sessionStore = sessionStore,
       _httpClient = httpClient ?? createAuthHttpClient(),
       _ownsHttpClient = httpClient == null;

  final String _baseUrl;
  final AuthSessionStore _sessionStore;
  final http.Client _httpClient;
  final bool _ownsHttpClient;
  final _controller = StreamController<AuthUser?>.broadcast();
  static const _requestTimeout = Duration(seconds: 12);
  static const _refreshSkew = Duration(minutes: 1);

  AuthUser? _currentUser;
  String? _accessToken;
  DateTime? _accessTokenExpiresAt;
  Future<void>? _restoreSessionInFlight;
  Future<String?>? _refreshSessionInFlight;
  int _sessionEpoch = 0;
  bool _disposed = false;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield await currentUser();
    yield* _controller.stream;
  }

  @override
  Future<String?> currentAccessToken() async {
    _accessToken ??= await _sessionStore.loadAccessToken();
    final token = _accessToken;
    final refreshToken = await _sessionStore.loadRefreshToken();
    if (token == null || token.isEmpty) {
      if (refreshToken == null || refreshToken.isEmpty) return null;
      return _refreshSession();
    }
    final expiry = _accessTokenExpiresAt ?? _jwtExpiry(token);
    _accessTokenExpiresAt = expiry;
    if (expiry != null &&
        !expiry.isAfter(DateTime.now().toUtc().add(_refreshSkew)) &&
        refreshToken != null &&
        refreshToken.isNotEmpty) {
      try {
        return await _refreshSession();
      } catch (_) {
        if (expiry.isAfter(DateTime.now().toUtc())) return token;
        rethrow;
      }
    }
    return token;
  }

  @override
  Future<String?> refreshAccessToken({String? failedAccessToken}) async {
    final current = _accessToken ?? await _sessionStore.loadAccessToken();
    if (failedAccessToken != null &&
        current != null &&
        current.isNotEmpty &&
        current != failedAccessToken) {
      return current;
    }
    return _refreshSession();
  }

  @override
  Future<AuthUser?> currentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    await _restoreSession();
    return _currentUser;
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    return _authenticate(
      path: '/v1/auth/sign-in',
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final passwordLength = utf8.encode(password).length;
    if (passwordLength < 10 || passwordLength > 72) {
      throw StateError('Password must be between 10 and 72 bytes.');
    }
    return _authenticate(
      path: '/v1/auth/sign-up',
      email: normalizedEmail,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    try {
      String? token;
      try {
        token = await currentAccessToken();
      } catch (_) {
        // Explicit sign-out must always clear the local session. A transient
        // refresh failure cannot leave the UI signed in.
      }
      _sessionEpoch += 1;
      await _httpClient
          .post(
            Uri.parse('$_baseUrl/v1/auth/sign-out'),
            headers: await _headers(token: token),
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw StateError(backendUnavailableMessage);
    } on http.ClientException {
      throw StateError(backendUnavailableMessage);
    } catch (error) {
      if (_isBackendConnectionError(error)) {
        throw StateError(backendUnavailableMessage);
      }
      rethrow;
    } finally {
      await _clearSession();
    }
  }

  Future<AuthUser> _authenticate({
    required String path,
    required String email,
    required String password,
  }) async {
    final expectedEpoch = ++_sessionEpoch;
    final response = await _postJson(
      Uri.parse('$_baseUrl$path'),
      body: {'email': email, 'password': password},
    );
    final payload = _tryDecodeJson(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (_isTransientSessionStatus(response.statusCode)) {
        throw StateError(backendUnavailableMessage);
      }
      _ensureSuccess(response, payload ?? const {});
    }
    if (payload == null) {
      throw StateError(
        'Authentication service returned an invalid response. '
        'Please try again.',
      );
    }
    return _persistSession(
      payload,
      expectedEpoch: expectedEpoch,
      replaceExisting: true,
    );
  }

  Future<void> _restoreSession() {
    final existing = _restoreSessionInFlight;
    if (existing != null) {
      return existing;
    }

    late final Future<void> operation;
    operation = _performSessionRestore().whenComplete(() {
      if (identical(_restoreSessionInFlight, operation)) {
        _restoreSessionInFlight = null;
      }
    });
    _restoreSessionInFlight = operation;
    return operation;
  }

  Future<void> _performSessionRestore() async {
    final expectedEpoch = _sessionEpoch;
    final storedToken = _accessToken ?? await _sessionStore.loadAccessToken();
    final storedRefreshToken = await _sessionStore.loadRefreshToken();
    final storedUser =
        await _sessionStore.loadCachedUser() ??
        (storedToken == null ? null : _cachedUserFromAccessToken(storedToken));
    final hasRefresh =
        storedRefreshToken != null && storedRefreshToken.isNotEmpty;
    if ((storedToken == null || storedToken.isEmpty) && !hasRefresh) {
      return;
    }
    if (expectedEpoch != _sessionEpoch) return;

    _accessToken = storedToken;
    _accessTokenExpiresAt = storedToken == null
        ? null
        : _jwtExpiry(storedToken);
    if (hasRefresh && storedUser != null) {
      if (expectedEpoch != _sessionEpoch) return;
      _currentUser = _authUserFromCache(storedUser);
      await _sessionStore.saveCachedUser(storedUser);
      if (expectedEpoch != _sessionEpoch) return;
      if (!_disposed) _controller.add(_currentUser);
      unawaited(_refreshRestoredSession().catchError((_) {}));
      return;
    }
    if (hasRefresh && (storedToken == null || storedToken.isEmpty)) {
      if (expectedEpoch != _sessionEpoch) return;
      await _refreshSession();
      return;
    }

    final response = await _get(
      Uri.parse('$_baseUrl/v1/auth/session'),
      token: storedToken!,
    );
    if (expectedEpoch != _sessionEpoch) return;
    if (response.statusCode == 401 || response.statusCode == 403) {
      if (hasRefresh) {
        await _refreshSession();
      } else {
        await _clearSession(expectedEpoch: expectedEpoch);
      }
      return;
    }
    if (_isTransientSessionStatus(response.statusCode)) {
      if (storedUser != null) {
        if (expectedEpoch != _sessionEpoch) return;
        _accessToken = storedToken;
        _currentUser = _authUserFromCache(storedUser);
        await _sessionStore.saveCachedUser(storedUser);
        if (expectedEpoch != _sessionEpoch) return;
        if (!_disposed) _controller.add(_currentUser);
        return;
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        response.statusCode >= 500
            ? backendUnavailableMessage
            : 'Session restore failed with status ${response.statusCode}.',
      );
    }

    final payload = _decodeJson(response);
    await _persistSession(
      payload,
      fallbackToken: storedToken,
      expectedEpoch: expectedEpoch,
    );
  }

  Future<void> _refreshRestoredSession() async {
    try {
      await currentAccessToken();
    } catch (_) {
      // Cached identity remains available for local-first use. A later
      // authenticated request will retry refresh when connectivity returns.
    }
  }

  Future<String?> _refreshSession() {
    final existing = _refreshSessionInFlight;
    if (existing != null) return existing;

    late final Future<String?> operation;
    operation = _performRefresh().whenComplete(() {
      if (identical(_refreshSessionInFlight, operation)) {
        _refreshSessionInFlight = null;
      }
    });
    _refreshSessionInFlight = operation;
    return operation;
  }

  Future<String?> _performRefresh() async {
    final expectedEpoch = _sessionEpoch;
    final refreshToken = await _sessionStore.loadRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    if (expectedEpoch != _sessionEpoch) return _accessToken;
    http.Response response;
    Map<String, dynamic>? payload;
    for (var attempt = 0; ; attempt += 1) {
      if (expectedEpoch != _sessionEpoch) return _accessToken;
      response = await _postJson(
        Uri.parse('$_baseUrl/v1/auth/refresh'),
        body: kIsWeb ? const {} : {'refreshToken': refreshToken},
      );
      if (expectedEpoch != _sessionEpoch) return _accessToken;
      payload = _tryDecodeJson(response);
      final code = payload?['code'] as String?;
      if (response.statusCode == 409 &&
          code == 'refresh_race' &&
          attempt == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 120));
        continue;
      }
      break;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (payload == null) {
        throw StateError(backendUnavailableMessage);
      }
      await _persistSession(payload, expectedEpoch: expectedEpoch);
      return _accessToken ?? (await _sessionStore.loadAccessToken());
    }

    final code = payload?['code'] as String?;
    if ((response.statusCode == 401 || response.statusCode == 403) &&
        const {
          'refresh_invalid',
          'refresh_expired',
          'refresh_reused',
          'session_invalid',
          'session_revoked',
        }.contains(code)) {
      await _clearSession(expectedEpoch: expectedEpoch);
      return null;
    }
    if (_isTransientSessionStatus(response.statusCode) || payload == null) {
      throw StateError(backendUnavailableMessage);
    }
    _ensureSuccess(response, payload);
    return null;
  }

  Future<http.Response> _postJson(
    Uri uri, {
    required Map<String, dynamic> body,
  }) async {
    try {
      return await _httpClient
          .post(uri, headers: await _headers(), body: jsonEncode(body))
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw StateError(backendUnavailableMessage);
    } on http.ClientException {
      throw StateError(backendUnavailableMessage);
    } on FormatException {
      throw StateError('Backend auth response was not valid JSON.');
    } catch (error) {
      if (_isBackendConnectionError(error)) {
        throw StateError(backendUnavailableMessage);
      }
      rethrow;
    }
  }

  Future<http.Response> _get(Uri uri, {String? token}) async {
    try {
      return await _httpClient
          .get(uri, headers: await _headers(token: token))
          .timeout(_requestTimeout);
    } on TimeoutException {
      return http.Response('', 503);
    } on http.ClientException {
      return http.Response('', 503);
    } catch (error) {
      if (_isBackendConnectionError(error)) {
        return http.Response('', 503);
      }
      rethrow;
    }
  }

  Future<AuthUser> _persistSession(
    Map<String, dynamic> payload, {
    String? fallbackToken,
    int? expectedEpoch,
    bool replaceExisting = false,
  }) async {
    _ensureSessionEpoch(expectedEpoch);
    final token =
        payload['accessToken'] as String? ??
        payload['access_token'] as String? ??
        fallbackToken;
    final userJson = payload['user'] as Map<String, dynamic>?;
    if (token == null || userJson == null) {
      throw StateError('Backend auth response is missing session data.');
    }
    final refreshToken = payload['refreshToken'] as String?;
    if (!kIsWeb &&
        payload['hasRefreshToken'] == true &&
        (refreshToken == null || refreshToken.isEmpty)) {
      throw StateError('Backend auth response is missing refresh data.');
    }

    final user = AuthUser(
      id: userJson['id'] as String,
      email: userJson['email'] as String?,
      displayName:
          userJson['displayName'] as String? ?? userJson['email'] as String?,
      isAnonymous: userJson['isAnonymous'] as bool? ?? false,
    );

    if (replaceExisting) {
      // A successful account change replaces the complete credential set. It
      // must not leave a previous account's refresh token behind when talking
      // to an older access-only backend.
      await _sessionStore.clear();
      _ensureSessionEpoch(expectedEpoch);
    }

    _accessToken = token;
    _accessTokenExpiresAt =
        DateTime.tryParse(
          payload['accessTokenExpiresAt'] as String? ?? '',
        )?.toUtc() ??
        _jwtExpiry(token);
    _currentUser = user;
    await _sessionStore.saveAccessToken(token);
    _ensureSessionEpoch(expectedEpoch);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _sessionStore.saveRefreshToken(refreshToken);
    } else if (kIsWeb && payload['hasRefreshToken'] == true) {
      await _sessionStore.saveRefreshToken(webRefreshCookieMarker);
    }
    _ensureSessionEpoch(expectedEpoch);
    await _sessionStore.saveCachedUser(_cachedAuthUser(user));
    _ensureSessionEpoch(expectedEpoch);
    if (!_disposed) _controller.add(user);
    return user;
  }

  void _ensureSessionEpoch(int? expectedEpoch) {
    if (expectedEpoch != null && expectedEpoch != _sessionEpoch) {
      throw StateError('Authentication state changed while the request ran.');
    }
  }

  Future<void> _clearSession({int? expectedEpoch}) async {
    if (expectedEpoch != null && expectedEpoch != _sessionEpoch) return;
    _sessionEpoch += 1;
    _currentUser = null;
    _accessToken = null;
    _accessTokenExpiresAt = null;
    await _sessionStore.clear();
    if (!_disposed) _controller.add(null);
  }

  bool _isTransientSessionStatus(int statusCode) {
    return statusCode == 408 || statusCode == 429 || statusCode >= 500;
  }

  CachedAuthUser? _cachedUserFromAccessToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic>) {
        return null;
      }
      final id = payload['sub'] as String?;
      if (id == null || id.isEmpty) {
        return null;
      }
      final email = payload['email'] as String?;
      return CachedAuthUser(id: id, email: email, displayName: email);
    } catch (_) {
      return null;
    }
  }

  CachedAuthUser _cachedAuthUser(AuthUser user) {
    return CachedAuthUser(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      isAnonymous: user.isAnonymous,
    );
  }

  AuthUser _authUserFromCache(CachedAuthUser user) {
    return AuthUser(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      isAnonymous: user.isAnonymous,
    );
  }

  Future<Map<String, String>> _headers({String? token}) async {
    final deviceId = await _sessionStore.loadOrCreateDeviceId();
    return {
      'Content-Type': 'application/json',
      'X-Fittin-Auth-Version': '2',
      'X-Fittin-Auth-Platform': kIsWeb ? 'web' : 'native',
      'X-Fittin-Device-Id': deviceId,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  DateTime? _jwtExpiry(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic>) return null;
      final rawExpiry = payload['exp'];
      final seconds = switch (rawExpiry) {
        int value => value,
        num value => value.toInt(),
        _ => null,
      };
      if (seconds == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    if (_ownsHttpClient) _httpClient.close();
    unawaited(_controller.close());
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    final payload = _tryDecodeJson(response);
    if (payload != null) {
      return payload;
    }
    throw StateError(
      'Authentication service returned an invalid response. '
      'Please try again.',
    );
  }

  Map<String, dynamic>? _tryDecodeJson(http.Response response) {
    if (response.body.isEmpty) {
      return const {};
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      return null;
    }
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  }

  void _ensureSuccess(http.Response response, Map<String, dynamic> payload) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    final message =
        payload['error'] as String? ??
        payload['message'] as String? ??
        'Auth request failed with status ${response.statusCode}.';
    throw StateError(message);
  }
}

bool _isBackendConnectionError(Object error) {
  final message = error.toString();
  return message.contains('SocketException') ||
      message.contains('Connection refused') ||
      message.contains('Failed host lookup') ||
      message.contains('Network is unreachable');
}

class UnavailableAuthRepository implements AuthRepository {
  UnavailableAuthRepository([this.message = 'Backend Auth is unavailable.']);

  final String message;

  @override
  Stream<AuthUser?> authStateChanges() => Stream<AuthUser?>.value(null);

  @override
  Future<String?> currentAccessToken() async => null;

  @override
  Future<String?> refreshAccessToken({String? failedAccessToken}) async => null;

  @override
  Future<AuthUser?> currentUser() async => null;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    throw StateError(message);
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    throw StateError(message);
  }

  @override
  Future<void> signOut() async {
    throw StateError(message);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final bootstrap = ref.watch(supabaseBootstrapProvider);
  final sessionStore = ref.watch(authSessionStoreProvider);
  if (!bootstrap.isConfigured) {
    return UnavailableAuthRepository(
      bootstrap.errorMessage ?? 'Backend Auth is unavailable.',
    );
  }
  final repository = BackendAuthRepository(
    baseUrl: bootstrap.url,
    sessionStore: sessionStore,
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.id;
});

class AuthControllerState {
  const AuthControllerState({
    this.isSubmitting = false,
    this.errorMessage,
    this.infoMessage,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final String? infoMessage;

  AuthControllerState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return AuthControllerState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      infoMessage: clearInfo ? null : infoMessage ?? this.infoMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthControllerState> {
  AuthController(this._repository) : super(const AuthControllerState());

  final AuthRepository _repository;

  Future<bool> signIn({required String email, required String password}) async {
    return _run(
      () => _repository.signIn(email: email, password: password),
      successMessage: 'Signed in.',
    );
  }

  Future<bool> signUp({required String email, required String password}) async {
    return _run(
      () => _repository.signUp(email: email, password: password),
      successMessage: 'Account created.',
    );
  }

  Future<bool> signOut() async {
    return _runVoid(_repository.signOut, successMessage: 'Signed out.');
  }

  void setValidationError(String message) {
    state = state.copyWith(
      errorMessage: message,
      clearInfo: true,
      isSubmitting: false,
    );
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearInfo: true);
  }

  Future<bool> _run(
    Future<AuthUser> Function() action, {
    required String successMessage,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearInfo: true,
    );
    try {
      await action();
      state = state.copyWith(
        isSubmitting: false,
        infoMessage: successMessage,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyError(error),
        clearInfo: true,
      );
      return false;
    }
  }

  Future<bool> _runVoid(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearInfo: true,
    );
    try {
      await action();
      state = state.copyWith(
        isSubmitting: false,
        infoMessage: successMessage,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyError(error),
        clearInfo: true,
      );
      return false;
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (_isBackendConnectionError(error) ||
        message.contains('ClientException')) {
      return backendUnavailableMessage;
    }
    if (error is StateError) {
      return error.message.toString();
    }
    if (message.startsWith('StateError: ')) {
      return message.substring('StateError: '.length);
    }
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthControllerState>((ref) {
      return AuthController(ref.watch(authRepositoryProvider));
    });
