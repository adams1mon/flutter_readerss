import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readrss/di.dart';
import 'package:flutter_readrss/presentation/ui/const/screen_route.dart';
import 'package:flutter_readrss/presentation/ui/pages/container_page.dart';
import 'package:flutter_readrss/presentation/ui/pages/login_page.dart';
import 'package:flutter_readrss/presentation/ui/pages/user_page.dart';
import 'package:flutter_readrss/presentation/ui/pages/webview_page.dart';
import 'package:flutter_readrss/presentation/ui/styles/styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    super.dispose();
    globalCleanup();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ReadRss',
        theme: globalTheme,
        initialRoute: ScreenRoute.main.route,
        routes: {
          ScreenRoute.main.route: (context) => const LoginDecider(),
          ScreenRoute.user.route: (context) => UserPage(
                title: "Account",
                signOut: authUseCases.signOut,
                deleteAccount: authUseCases.deleteUser,
              ),
          ScreenRoute.webview.route: (context) => const ArticleWebViewPage(),
        });
  }
}

class LoginDecider extends StatelessWidget {
  const LoginDecider({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authUseCases.getUserChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("An unknown error occurred.");
        }

        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data == null) {
            // login needed
            return LoginPage(
              register: authUseCases.registerWithEmailAndPassword,
              login: authUseCases.loginWithEmailAndPassword,
            );
          } else {
            // user loaded from disk
            return const ContainerPage();
          }
        }

        // this shouldn't be reached ever
        throw Exception("Error while consuming from user changes stream");
      },
    );
  }
}
