import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_readrss/use_case/auth/user_repository.dart';
import 'package:flutter_readrss/use_case/feeds/feed_presenter.dart';

import '../auth_use_cases.dart';
import '../../exceptions/use_case_exception.dart';

/// Class which implements [AuthUseCases] using Firebase Auth,
/// wraps the Firebase auth state change events with our specific [AuthEvent] events,
/// which other application can listen to.
class AuthUseCasesImpl implements AuthUseCases {
  User? _user;
  final _authEvents = StreamController<AuthEvent>.broadcast();
  final UserRepository _userRepository;
  final FeedPresenter _feedPresenter;

  AuthUseCasesImpl({required userRepository, required feedPresenter})
      : _userRepository = userRepository,
        _feedPresenter = feedPresenter {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        // fire a login event
        _authEvents.add(AuthEvent(type: AuthEventType.login, user: _user));
      }
    });
  }

  @override
  User? getUser() => _user;

  @override
  Stream<AuthEvent> getAuthEventStream() => _authEvents.stream;

  @override
  void loginAsGuest() {
    _user = null;
    _authEvents.add(AuthEvent(type: AuthEventType.guestLogin, user: null));
  }

  @override
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      log('sign in: $userCredential');
      _user = userCredential.user;
      _authEvents.add(AuthEvent(type: AuthEventType.login, user: _user));
    } on FirebaseAuthException catch (e) {
      // TODO: do these when validating things locally, not by Firebase
      switch (e.code) {
        case 'weak-password':
          throw UseCaseException('The password provided is too weak.');
        case 'invalid-email':
          throw UseCaseException('Invalid email address');
        case 'email-already-in-use':
          throw UseCaseException(
              'An account already exists for this email address.');
      }
    } catch (e) {
      throw UseCaseException(
          'Registration failed. Try a different email or password.');
    }
  }

  @override
  Future<void> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      log('register: $userCredential');
      _user = userCredential.user;
      _authEvents.add(AuthEvent(type: AuthEventType.login, user: _user));
    } on FirebaseAuthException catch (e) {
      // TODO: do these when validating things locally, not by Firebase
      switch (e.code) {
        case 'weak-password':
          throw UseCaseException('The password provided is too weak.');
        case 'invalid-email':
          throw UseCaseException('Invalid email address');
        case 'email-already-in-use':
          throw UseCaseException(
              'An account already exists for this email address.');
      }
    } catch (e) {
      throw UseCaseException(
          'Registration failed. Try a different email or password.');
    }
  }

  @override
  Future<void> signOut() async {
    if (_user == null) return;
    await FirebaseAuth.instance.signOut();
    _user = null;
    _authEvents.add(AuthEvent(type: AuthEventType.signOut, user: null));
    _feedPresenter.clearAllFeeds(); 
  }

  @override
  Future<void> deleteUser() async {
    if (_user == null) return;

    await _userRepository.deleteUser(_user!.uid);
    await _user?.delete();
    _user = null;
    _authEvents.add(AuthEvent(type: AuthEventType.delete, user: _user));
    _feedPresenter.clearAllFeeds();
  }
}
