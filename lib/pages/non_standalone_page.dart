import 'package:flutter/material.dart';

class NonStandalonePage extends StatelessWidget {
  const NonStandalonePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: "Jelly Crush",
        debugShowCheckedModeBanner: false,
        home: Scaffold( body: Center(child:
            Text('Bitte fügen Sie dazu diese Seite auf Ihren Homescreen/Startbildschirm hinzu, '
                'danach können Sie das Spiel wie jede andere App handhaben. Die Installation '
                'funktioniert wie folgt: \n'
                'für Android (alle Handys außer iPhone): Drücken Sie '
                'auf die drei kleinen Punkte rechts oben auf dem Bildschirm -> App installieren'
                '\n'
                'für Apple (iPhone): Drücken Sie auf den „Teilen“-Button (kleines Viereck mit '
                'dem Pfeil nach oben) -> Option -> zum Home-Bildschirm',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  decoration: TextDecoration.none),
            ))));
  }
}
