import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:fittin_v2/src/application/auth_session_store.dart';
import 'package:fittin_v2/src/application/supabase_bootstrap.dart';

const backendUnavailableMessage =
    'Backend service is unavailable. For Web/Android release builds, pass '
    '--dart-define=BACKEND_URL=https://api.yimelo.cc. For local development, '
    'start the backend or provide BACKEND_URL explicitly.';

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
       _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final AuthSessionStore _sessionStore;
  final http.Client _httpClient;
  final _controller = StreamController<AuthUser?>.broadcast();
  static const _requestTimeout = Duration(seconds: 12);

  AuthUser? _currentUser;
  String? _accessToken;
  Future<void>? _restoreSessionInFlight;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield await currentUser();
    yield* _controller.stream;
  }

  @override
  Future<String?> currentAccessToken() async {
    _accessToken ??= await _sessionStore.loadAccessToken();
    return _accessToken;
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
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    return _authenticate(
      path: '/v1/auth/sign-up',
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    final token = await currentAccessToken();
    try {
      await _httpClient
          .post(
            Uri.parse('$_baseUrl/v1/auth/sign-out'),
            headers: _headers(token: token),
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
      _currentUser = null;
      _accessToken = null;
      await _sessionStore.clear();
      _controller.add(null);
    }
  }

  Future<AuthUser> _authenticate({
    required String path,
    required String email,
    required String password,
  }) async {
    final response = await _postJson(
      Uri.parse('$_baseUrl$path'),
      body: {'email': email, 'password': password},
    );
    final payload = _decodeJson(response);
    _ensureSuccess(response, payload);
    return _persistSession(payload);
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
    final storedToken = _accessToken ?? await _sessionStore.loadAccessToken();
    if (storedToken == null || storedToken.isEmpty) {
      return;
    }

    final response = await _get(
      Uri.parse('$_baseUrl/v1/auth/session'),
      token: storedToken,
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      _currentUser = null;
      _accessToken = null;
      await _sessionStore.clear();
      _controller.add(null);
      return;
    }
    if (_isTransientSessionStatus(response.statusCode)) {
      final storedUser =
          await _sessionStore.loadCachedUser() ??
          _cachedUserFromAccessToken(storedToken);
      if (storedUser != null) {
        _accessToken = storedToken;
        _currentUser = _authUserFromCache(storedUser);
        await _sessionStore.saveCachedUser(storedUser);
        _controller.add(_currentUser);
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
    await _persistSession(payload, fallbackToken: storedToken);
  }

  Future<http.Response> _postJson(
    Uri uri, {
    required Map<String, dynamic> body,
  }) async {
    try {
      return await _httpClient
          .post(uri, headers: _headers(), body: jsonEncode(body))
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
          .get(uri, headers: _headers(token: token))
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
  }) async {
    final token =
        payload['accessToken'] as String? ??
        payload['access_token'] as String? ??
        fallbackToken;
    final userJson = payload['user'] as Map<String, dynamic>?;
    if (token == null || userJson == null) {
      throw StateError('Backend auth response is missing session data.');
    }

    final user = AuthUser(
      id: userJson['id'] as String,
      email: userJson['email'] as String?,
      displayName:
          userJson['displayName'] as String? ?? userJson['email'] as String?,
      isAnonymous: userJson['isAnonymous'] as bool? ?? false,
    );

    _accessToken = token;
    _currentUser = user;
    await _sessionStore.saveAccessToken(token);
    await _sessionStore.saveCachedUser(_cachedAuthUser(user));
    _controller.add(user);
    return user;
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

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.body.isEmpty) {
      return const {};
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw StateError('Backend auth response was not valid JSON.');
    }
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw StateError('Backend auth response must be a JSON object.');
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
  return BackendAuthRepository(
    baseUrl: bootstrap.url,
    sessionStore: sessionStore,
  );
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
