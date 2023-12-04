import 'package:flutter/material.dart';

class NonStandalonePage extends StatelessWidget {
  const NonStandalonePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Jelly Crush",
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
                child: ListView(padding: const EdgeInsets.all(20), children: const [
          Text(
            'Bitte fügen Sie diese Seite auf Ihren Homescreen/Startbildschirm hinzu, '
            'danach können Sie das Spiel wie jede andere App handhaben. Die Installation '
            'funktioniert wie folgt: \n'
            'für Android (alle Handys außer iPhone): Drücken Sie '
            'auf die drei kleinen Punkte rechts oben auf dem Bildschirm -> App installieren',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                backgroundColor: Colors.white,
                decoration: TextDecoration.none),
          ),
          Image(image: AssetImage('assets/instructions/InstallAppAndroid.jpg'), fit: BoxFit.cover),
          Text(
            'für Apple (iPhone): Drücken Sie auf den „Teilen“-Button (kleines Viereck mit '
            'dem Pfeil nach oben) -> Option -> zum Home-Bildschirm',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                backgroundColor: Colors.white,
                decoration: TextDecoration.none),
          ),
        ]))));
  }
}
