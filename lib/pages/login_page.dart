import 'package:flutter/material.dart';
import 'package:flutter_readrss/styles/colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors(context).background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("ReadRss",
                style: TextStyle(
                  color: colors(context).primary,
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Arial",
                )),
            const SizedBox(
              height: 160,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                backgroundColor: colors(context).primary,
                foregroundColor: colors(context).onPrimary,
                minimumSize: const Size(340, 40),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(
              height: 10,
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                backgroundColor: colors(context).surface,
                foregroundColor: colors(context).onSurface,
                minimumSize: const Size(340, 40),
              ),
              child: const Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
