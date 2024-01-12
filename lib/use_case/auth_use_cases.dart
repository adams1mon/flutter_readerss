
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_readrss/use_case/exceptions/use_case_exceptions.dart';

// TODO: ideally we would wrap UserCredential and User in custom business objects to abstract away Firebase completely
abstract class AuthUseCases {
  Future<UserCredential?> registerWithEmailAndPassword(String email, String password);
  Future<UserCredential?> loginWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> deleteUser();

  User? getUser();
  Stream<User?> getUserChanges();
}


// TODO: wrap events correctly: register, login, signout, delete; propagate these instead of Firebase events

class AuthUseCasesImpl implements AuthUseCases {

  AuthUseCasesImpl() {
    _userChanges
      .listen((User? user) {
        log('user event: $user');
        _user = user;
      });
  }

  final Stream<User?> _userChanges = FirebaseAuth.instance.authStateChanges();
  User? _user;

  @override 
  User? getUser() => _user;

  @override
  Stream<User?> getUserChanges() => _userChanges;

  @override
  Future<UserCredential?> loginWithEmailAndPassword(String email, String password) async {
   try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      log('sign in: $userCredential');

      return userCredential;

    } on FirebaseAuthException catch (e) {
      // TODO: do these when validating things locally, not by Firebase
      switch (e.code) {
        case 'weak-password':
          throw UseCaseException('The password provided is too weak.'); 
        case 'invalid-email':
          throw UseCaseException('Invalid email address');
        case 'email-already-in-use':
          throw UseCaseException('An account already exists for this email address.');
      }
    } catch (e) {
      throw UseCaseException('Registration failed. Try a different email or password.');
    } 
    return null;
  }

  @override
  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      log('sign in: $userCredential');

      return userCredential;

    } on FirebaseAuthException catch (e) {
      // TODO: do these when validating things locally, not by Firebase
      switch (e.code) {
        case 'weak-password':
          throw UseCaseException('The password provided is too weak.'); 
        case 'invalid-email':
          throw UseCaseException('Invalid email address');
        case 'email-already-in-use':
          throw UseCaseException('An account already exists for this email address.');
      }
    } catch (e) {
      throw UseCaseException('Registration failed. Try a different email or password.');
    }
    return null;
  }

  @override
  Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> deleteUser() {
    return FirebaseAuth.instance.currentUser?.delete() ?? Future.value();
  }
}