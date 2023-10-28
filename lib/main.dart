import 'package:flutter/material.dart';
import 'package:flutter_readrss/pages/feed_page.dart';
import 'package:flutter_readrss/styles/styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: globalTheme,
      // home: const LoginPage(),
      home: const FeedPage(),
    );
  }
}
