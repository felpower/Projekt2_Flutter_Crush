import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class NonMobilePage extends StatelessWidget {
  const NonMobilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return MaterialApp(
        title: "Kein Mobiles Endgerät",
        theme: ThemeData.light(),
        darkTheme: ThemeData.light(),
        themeMode: ThemeMode.light,
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
