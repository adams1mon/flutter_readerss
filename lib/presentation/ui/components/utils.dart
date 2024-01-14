import 'package:flutter/material.dart';
import 'package:flutter_readrss/presentation/ui/const/screen_route.dart';

void navigateToNewRoot(BuildContext context, ScreenRoute root) {
  Navigator.of(context).pushNamedAndRemoveUntil(root.route, (route) => false);
}