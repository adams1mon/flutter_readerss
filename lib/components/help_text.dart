import 'package:flutter/material.dart';
import 'package:flutter_readrss/styles/styles.dart';

class HelpText extends StatelessWidget {
  const HelpText({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        child: Text(
          text,
          style: textTheme(context).bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
