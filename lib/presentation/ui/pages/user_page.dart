
import 'package:flutter/material.dart';

import '../components/app_bar.dart';
import '../styles/styles.dart';

// TODO: refine this page a bit; maybe put account settings under normal settings??
class UserPage extends StatelessWidget {
  const UserPage({
    super.key,
    required this.title,
    required this.signOut,
    required this.deleteAccount,
  });

  final String title;
  final Future<void> Function() signOut;
  final Future<void> Function() deleteAccount;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: ReadrssAppBar(
        title: title,
        context: context,
      ),
      backgroundColor: colors(context).background,
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: signOut,
              style: TextButton.styleFrom(
                backgroundColor: colors(context).primary,
                foregroundColor: colors(context).onPrimary,
              ),
              child: const Text("Sign Out"),
            ),
            TextButton(
              onPressed: deleteAccount,
              style: TextButton.styleFrom(
                backgroundColor: colors(context).error,
                foregroundColor: colors(context).onError,
              ),
              child: const Text("Delete Account"),
            ),
          ],
        ),       
      ),
    );
  }
}
