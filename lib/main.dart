import 'package:flutter/material.dart';
import 'package:flutter_readrss/presentation/ui/const/screen_route.dart';
import 'package:flutter_readrss/presentation/ui/pages/container_page.dart';
import 'package:flutter_readrss/presentation/ui/pages/login_page.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ReadRss',
        theme: globalTheme,
        initialRoute: ScreenRoute.login.route,
        routes: {
          ScreenRoute.login.route: (context) => const LoginPage(),
          ScreenRoute.main.route: (context) => const ContainerPage(),
          // TODO: create the user account page ?
          ScreenRoute.user.route: (context) =>
              const Text("User account page here"),
          ScreenRoute.webview.route: (context) => const ArticleWebViewPage(),
        });
  }
}
