import 'package:flutter/material.dart';
import 'package:flutter_readrss/di.dart';
import 'package:flutter_readrss/presentation/ui/components/avatars.dart';
import 'package:flutter_readrss/presentation/ui/components/utils.dart';

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
                      onTap: () => Navigator.pushNamed(
                        context,
                        ScreenRoute.user.route,
                      ),
                      child: UserAvatar(
                        image: authUseCases.getUser()?.photoURL != null
                            ? Image.network(authUseCases.getUser()!.photoURL!)
                            : Image.asset("assets/avatar.jpg"),
                      ),
                    )
                  : TextButton(
                      onPressed: () {
                        // go to the initial page
                        navigateToNewRoot(context, ScreenRoute.main);
                      },
                      child: const Text("Sign In"),
                    ),
            ),
          ],
        );
}
