import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

/// Interface to handle user authn & authz use cases
abstract class AuthUseCases {
  Future<void> registerWithEmailAndPassword(String email, String password);
  Future<void> loginWithEmailAndPassword(String email, String password);
  void loginAsGuest();
  Future<void> signOut();
  Future<void> deleteUser();

  /// Returns the currently logged in [User], or null, there is not logged in user.
  User? getUser();

  /// Returns a stream of auth state changes in form of [AuthEvent] events.
  Stream<AuthEvent> getAuthEventStream();
}

class AuthEvent {
  AuthEvent({required this.type, required this.user});
  AuthEventType type;
  // TODO: ideally this should be wrapped by our specific 'User' model 
  User? user;
}

enum AuthEventType {
  init, // used to allow stream initialization
  login,
  guestLogin,
  signOut,
  delete,
}