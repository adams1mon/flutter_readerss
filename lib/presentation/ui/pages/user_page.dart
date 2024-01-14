import 'package:flutter/material.dart';
import 'package:flutter_readrss/presentation/ui/const/screen_page.dart';

import '../components/app_bar.dart';
import '../styles/styles.dart';

// TODO: refine this page a bit; maybe put account settings under normal settings??
class UserPage extends StatelessWidget {
  const UserPage({
    super.key,
    required this.signOut,
    required this.deleteAccount,
  });

  final Future<void> Function() signOut;
  final Future<void> Function() deleteAccount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReadrssAppBar(
        title: ScreenPage.account.title,
        context: context,
      ),
      backgroundColor: colors(context).background,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 25.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: colors(context).primary,
                  foregroundColor: colors(context).onPrimary,
                ),
                onPressed: signOut,
                child: const Text("Sign Out"),
              ),
              const SizedBox(height: 20.0,),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: colors(context).error,
                  foregroundColor: colors(context).onError,
                ),
                onPressed: () => showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text("Delete Account"),
                    content: const Text("Are you sure you want to delete your account?"),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        onPressed: deleteAccount,
                        child: Text(
                          'Delete',
                          style: TextStyle(color: colors(dialogContext).error),
                        ),
                      ),
                    ],
                  ),
                ),
                child: const Text("Delete Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
