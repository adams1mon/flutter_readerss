import 'package:flutter/material.dart';
import 'package:flutter_readrss/presentation/ui/components/avatars.dart';

import '../pages/screen_route.dart';

// TODO: get this state from somewhere
const loggedIn = false;

class ReadrssAppBar extends AppBar {
  ReadrssAppBar(
      {super.key, required String title, required BuildContext context})
      : super(
          title: Text(title),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: loggedIn
                  ? GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(
                            context,
                            ScreenRoute.user.route,
                          ),
                      child:
                          UserAvatar(image: Image.asset("assets/avatar.jpg")))
                  : TextButton(
                      // TODO: take me to the login page ?
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        ScreenRoute.login.route,
                      ),
                      child: const Text("Register"),
                    ),
            ),
          ],
        );
}
