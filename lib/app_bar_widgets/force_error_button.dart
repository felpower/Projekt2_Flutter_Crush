import 'package:flutter/material.dart';

class ForceErrorButton extends StatelessWidget {
  const ForceErrorButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: IconButton(
          onPressed: () {
            throw Exception('This is a forced exception for testing purposes.');
          },
          icon: const Icon(Icons.error)),
    );
  }
}
