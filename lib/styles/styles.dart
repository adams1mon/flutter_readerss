import 'package:flutter/material.dart';

final globalTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
);

ColorScheme colors(BuildContext context) {
  return Theme.of(context).colorScheme;
}

TextTheme textTheme(BuildContext context) {
  return Theme.of(context).textTheme;
}

final defaultFeedImage = Image.asset("assets/newspaper.png");

const borderRadius = 10.0;
const userAvatarWidth = 40.0;
const feedAvatarWidth = 50.0;

OutlinedBorder roundedBorders() {
  return const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
    Radius.circular(borderRadius),
  ));
}
