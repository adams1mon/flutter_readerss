import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_readrss/di.dart';
import 'package:flutter_readrss/presentation/ui/components/avatars.dart';

import '../const/screen_route.dart';


class ReadrssAppBar extends AppBar {
  ReadrssAppBar(
      {super.key, required String title, required BuildContext context})
      : super(
          title: Text(title),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: authUseCases.getUser() != null
                  ? GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(
                            context,
                            ScreenRoute.user.route,
                          ),
                      child:
                          UserAvatar(image: Image.asset("assets/avatar.jpg")))
                  : TextButton(
                      // TODO: take me to the login page ?
                      onPressed: () => log('register user stub'),
                      child: const Text("Register"),
                    ),
            ),
          ],
        );
}
