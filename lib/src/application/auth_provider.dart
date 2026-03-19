import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/supabase_bootstrap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> signUp({required String email, required String password});

  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _client.auth.onAuthStateChange.map(
      (state) => _mapUser(state.session?.user),
    );
  }

  @override
  Future<AuthUser?> currentUser() async => _mapUser(_client.auth.currentUser);

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = _mapUser(response.user);
    if (user == null) {
      throw StateError('Supabase did not return a signed-in user.');
    }
    return user;
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    final user = _mapUser(response.user);
    if (user == null) {
      throw StateError('Supabase did not return a created user.');
    }
    return user;
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  AuthUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }
    return AuthUser(
      id: user.id,
      email: user.email,
      displayName:
          (user.userMetadata?['display_name'] as String?) ?? user.email,
      isAnonymous: user.isAnonymous,
    );
  }
}

class UnavailableAuthRepository implements AuthRepository {
  UnavailableAuthRepository([this.message = 'Supabase Auth is unavailable.']);

  final String message;

  @override
  Stream<AuthUser?> authStateChanges() => Stream<AuthUser?>.value(null);

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
  final client = ref.watch(supabaseClientProvider);
  if (!bootstrap.isConfigured || client == null) {
    return UnavailableAuthRepository(
      bootstrap.errorMessage ?? 'Supabase Auth is unavailable.',
    );
  }
  return SupabaseAuthRepository(client);
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
    if (error is AuthException) {
      return error.message;
    }
    return error.toString();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthControllerState>((ref) {
      return AuthController(ref.watch(authRepositoryProvider));
    });
