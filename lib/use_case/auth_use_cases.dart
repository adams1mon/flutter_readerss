import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_readrss/use_case/exceptions/use_case_exceptions.dart';

// TODO: ideally we would wrap UserCredential and User in custom business objects to abstract away Firebase completely
abstract class AuthUseCases {
  Future<void> registerWithEmailAndPassword(String email, String password);
  Future<void> loginWithEmailAndPassword(String email, String password);
  void loginAsGuest();
  Future<void> signOut();
  Future<void> deleteUser();

  // returns null if the user is not logged in, or if a guest user is used
  User? getUser();
  Stream<AuthEvent> getAuthEventStream();
}

enum AuthEventType {
  init, // used to allow stream initialization
  register,
  login,
  guestLogin,
  signOut,
  delete,
}

class AuthEvent {
  AuthEvent({required this.type, required this.user});
  AuthEventType type;
  // TODO: this should be wrapped ideally
  User? user;
}

class AuthUseCasesImpl implements AuthUseCases {

  User? _user;
  final _authEvents = StreamController<AuthEvent>.broadcast();

  AuthUseCasesImpl() {
    FirebaseAuth.instance.authStateChanges()
    .listen((User? user) {
      _user = user;
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
      _authEvents.add(AuthEvent(type: AuthEventType.login,user: _user));
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
  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
  }

  @override
  Future<void> deleteUser() async {
    if (_user == null) return;
    await _user?.delete();
    _user = null;
    _authEvents.add(AuthEvent(type: AuthEventType.delete, user: _user));
  }
}
