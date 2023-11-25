import 'package:flutter/material.dart';
import 'package:flutter_readrss/const/screen_route.dart';
import 'package:flutter_readrss/pages/container_page.dart';
import 'package:flutter_readrss/pages/login_page.dart';
import 'package:flutter_readrss/pages/webview_page.dart';
import 'package:flutter_readrss/styles/styles.dart';

void main() {
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
          ScreenRoute.user.route: (context) => const Text("User account page here"),

          // TODO: put webview and configure data passing
          ScreenRoute.webview.route: (context) => const ArticleWebViewPage(),
        });
  }
}
