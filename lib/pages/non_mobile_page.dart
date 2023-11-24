import 'package:flutter/material.dart';

class NonMobilePage extends StatelessWidget {
  const NonMobilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Error",
        debugShowCheckedModeBanner: false,
        home: Container(
            alignment: Alignment.center,
            child: const Text(
              'Diese Applikation ist ausschließlich für Mobile Endgeräte!',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  decoration: TextDecoration.none),
            )));
  }
}
