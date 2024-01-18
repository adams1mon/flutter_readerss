import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.text = "Loading..."});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(),
        ),
        const SizedBox(
          height: 25,
        ),
        const CircularProgressIndicator(),
      ],
    );
  }
}