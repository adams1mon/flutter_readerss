import 'package:flutter/material.dart';

ColorScheme colors(BuildContext context) {
  return Theme.of(context).colorScheme;
}

TextTheme textTheme(BuildContext context) {
  return Theme.of(context).textTheme;
}

const BORDER_RADIUS = 10.0;

OutlinedBorder roundedBorders() {
  return const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
    Radius.circular(BORDER_RADIUS),
  ));
}
