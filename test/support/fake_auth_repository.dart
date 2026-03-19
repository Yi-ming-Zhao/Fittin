import 'dart:async';

import 'package:fittin_v2/src/application/auth_provider.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthUser? initialUser}) {
    _currentUser = initialUser;
  }

  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;
  bool signedOut = false;
  int signInCalls = 0;
  int signUpCalls = 0;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<AuthUser?> currentUser() async => _currentUser;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls += 1;
    _currentUser = AuthUser(id: 'user-1', email: email);
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    signUpCalls += 1;
    _currentUser = AuthUser(id: 'user-2', email: email);
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    signedOut = true;
    _currentUser = null;
    _controller.add(null);
  }
}
