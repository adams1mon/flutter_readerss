import 'package:flutter/cupertino.dart';

import '../../../di.dart';
import '../../../use_case/auth/auth_use_cases.dart';
import 'container_page.dart';
import 'login_page.dart';

/// Widget which listens to [AuthEvent] events and decides to show
/// the [LoginPage] or [ContainerPage] with the main content when auth events
/// occur.
class LoginDecider extends StatelessWidget {
  const LoginDecider({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthEvent>(
      stream: authUseCases.getAuthEventStream(),
      initialData: AuthEvent(type: AuthEventType.init, user: null),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("An unknown error occurred.");
        }

        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.connectionState == ConnectionState.waiting) {
          return LoginPage(
            register: authUseCases.registerWithEmailAndPassword,
            login: authUseCases.loginWithEmailAndPassword,
            guestLogin: authUseCases.loginAsGuest,
          );
        }

        if (snapshot.connectionState == ConnectionState.active) {
          switch (snapshot.data?.type) {
            case AuthEventType.signOut ||
                  AuthEventType.delete ||
                  AuthEventType.init ||
                  null:
              // login or register
              return LoginPage(
                register: authUseCases.registerWithEmailAndPassword,
                login: authUseCases.loginWithEmailAndPassword,
                guestLogin: authUseCases.loginAsGuest,
              );
            case AuthEventType.login || AuthEventType.guestLogin:
              return const ContainerPage();
          }
        }

        // this shouldn't be reached ever
        throw Exception("Error while consuming from user changes stream");
      },
    );
  }
}
