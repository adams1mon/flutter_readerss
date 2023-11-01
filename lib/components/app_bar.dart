import 'package:flutter/material.dart';
import 'package:flutter_readrss/components/avatars.dart';

class ReadrssAppBar extends AppBar {
  ReadrssAppBar(
      {super.key,
      required String title,
      required UserAvatar userAvatar,
      required BuildContext context})
      : super(
          title: Text(title),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/settings');
                },
                child: userAvatar,
              ),
            ),
          ],
        );
}
