import 'package:flutter/material.dart';
import 'package:flutter_readrss/di.dart';
import 'package:flutter_readrss/presentation/ui/components/utils.dart';
import 'package:flutter_readrss/presentation/ui/const/screen_route.dart';
import 'package:flutter_readrss/presentation/ui/pages/login_decider.dart';
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
      home: const LoginDecider(),
      routes: {
        // we only use routing for the 'navigate back' functionality;
        // only use it for pages that can be navigated back from,
        // otherwise handle everything in the 'main' route
        ScreenRoute.main.route: (context) => const LoginDecider(),
        ScreenRoute.user.route: (context) => UserPage(
              signOut: () {
                // LoginDecider handles the new sign out event
                navigateToNewRoot(context, ScreenRoute.main);
                return authUseCases.signOut();
              },
              deleteAccount: () {
                // LoginDecider handles the new delete user event
                navigateToNewRoot(context, ScreenRoute.main);
                return authUseCases.deleteUser();
              },
            ),
        ScreenRoute.webview.route: (context) => const ArticleWebViewPage(),
      },
    );
  }
}
