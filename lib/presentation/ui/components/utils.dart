import 'package:flutter/material.dart';
import 'package:flutter_readrss/presentation/ui/const/screen_route.dart';

void navigateToNewRoot(BuildContext context, ScreenRoute root) {
  Navigator.of(context).pushNamedAndRemoveUntil(root.route, (route) => false);
}

void showAuthDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Authentication required"),
          content: Text(message),
          actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: () {
            // navigate to first screen (checks the login)
            navigateToNewRoot(context, ScreenRoute.main);
          },
          child: const Text('Sign In'),
        ),
          ], 
        );
      },
    );
}

void snackbarMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

