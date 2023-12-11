import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import '../bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import '../services/firebase_messaging.dart';

class DeviceToken extends StatefulWidget {
  const DeviceToken({Key? key}) : super(key: key);

  @override
  State<DeviceToken> createState() => _DeviceTokenState();
}

class _DeviceTokenState extends State<DeviceToken> {
  String text = "";
  TextEditingController authorizationStatus = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final DarkPatternsState darkPatternsState =
        flutter_bloc.BlocProvider.of<DarkPatternsBloc>(context).state;
    return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Instruktionen zum Spiel')),
        ),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Visibility(
            visible: false,
            child: FutureBuilder<String>(
                future: FirebaseMessagingWeb.getToken(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                    text = snapshot.data!;
                    return SelectableText(snapshot.data!);
                  }
                  return const CircularProgressIndicator();
                }),
          ),
          Visibility(
            visible: false,
            child: ElevatedButton(
              child: const Text('Copy'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: text)).then((result) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Device Token copied to ClipBoard successfully'),
                    duration: Duration(seconds: 1),
                  ));
                });
              },
            ),
          ),
          Visibility(
            visible: false,
            child: ElevatedButton(
              child: const Text('Token not showing, reload page'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Visibility(
            visible: false,
            child: ElevatedButton(
                child: const Text('Check Push Permission'),
                onPressed: () {
                  getNotification();
                  if (darkPatternsState is DarkPatternsActivatedState ||
                      darkPatternsState is DarkPatternsAppointmentState) {
                    FirebaseMessagingWeb.requestPermission();
                  }
                }),
          ),
          Visibility(
            visible: false,
            child: TextField(
                controller: authorizationStatus, textAlign: TextAlign.center, readOnly: true),
          ),
          const Text('''1.	Spielbrett und Jellies: ''',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const Text(
              '''Das Spielbrett ist ein Gitter mit verschiedenen farbigen Jellies. Jedes Jelly hat eine einzigartige Farbe und Form. (siehe Bild)
          '''),
          const Image(image: AssetImage('assets/instructions/ins_1.png'), fit: BoxFit.cover),
          const SizedBox(height: 20),
          const Text('''2.	Spielzüge:''', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text(
              '''Tausche zwei benachbarte Jellies, um eine Reihe oder Spalte von mindestens drei gleichfarbigen Jellies zu bilden.
              '''),
          const Image(image: AssetImage('assets/instructions/ins_2.png'), fit: BoxFit.cover),
          const SizedBox(width: 10, height: 20),
          const Text("3.	Kombinationen und Boni:", style: TextStyle(fontWeight: FontWeight.bold)),
          const Padding(
              padding: EdgeInsets.only(left: 20.0), // Adjust the value for the desired indent
              child: Text(
                  '''•	Kombiniere 4 Jellies, um ein spezielles Jelly zu erhalten, das eine ganze Reihe oder Spalte löschen kann. ''')),
          const Image(image: AssetImage('assets/images/bombs/jelly_gelb.png'), height: 30),
          const Padding(
              padding: EdgeInsets.only(left: 20.0), // Adjust the value for the desired indent
              child: Text('''
  •	Kombiniere 5 Jellies in einer T- oder L-Form, um ein Regenbogen-Jelly zu bekommen, das alle   Jellies einer bestimmten Farbe vom Brett entfernt.''')),
          const Image(image: AssetImage('assets/images/bombs/jelly_bunt.png'), height: 30),
          const Text("4.	Levelziele:", style: TextStyle(fontWeight: FontWeight.bold)),
          const Text(
              '''Jedes Level hat spezifische Ziele, wie das Erreichen einer bestimmten Punktzahl, das Sammeln einer Anzahl von bestimmten Jellies oder das Entfernen von Hindernissen. Das jeweilige Ziel wird in dem Kasten rechts oben auf dem Bildschirm angezeigt
              '''),
          const Image(image: AssetImage('assets/instructions/ins_3.png'), fit: BoxFit.cover),
          const SizedBox(width: 10, height: 20),
          const Text("5.	Bewegungsbegrenzung und Zeitlimit: ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const Text(
              '''Einige Level haben eine begrenzte Anzahl von Zügen oder ein Zeitlimit, um die Ziele zu erreichen. Dies wird in dem Kasten links oben auf dem Bildschirm angezeigt.
          '''),
          const Image(image: AssetImage('assets/instructions/ins_4.png'), fit: BoxFit.cover),
          const SizedBox(width: 10, height: 20),
          const Text("6.	Booster: ", style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('''
Nutze Booster bzw. Sonderjellies, um schwierige Level zu meistern. Diese können durch Spielverlauf oder Käufe (direkt vor dem Levelstart) erworben werden.'''),
          const SizedBox(width: 10, height: 20),
          const Text("7.	Fortschritt und Herausforderungen: ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const Text(
              '''Schalte neue Level und Herausforderungen frei, indem du im Spiel fortschreitest.'''),
          const SizedBox(width: 10, height: 20),
          const Text("8.	Startbildschirm: ", style: TextStyle(fontWeight: FontWeight.bold)),
          darkPatternsState is DarkPatternsActivatedState
              ? const Text(
                  '''Im Hauptmenü siehst du welche Level du bereits freigespielt hast (Kästchen hat eine deckende Farbe (1)), wie viele XP du hast (2)– diese bestimmten auch den Rang in der Highscore-Tafel (3), sowie die Anzahl an Münzen (4) (diese kannst du nutzen um Booster zu kaufen). Im Menü (5) kannst du diese Instruktionen jederzeit erneut durchlesen, solltest du etwas vergessen haben. ''')
              : const Text(
                  '''Im Hauptmenü siehst du welche Level du bereits freigespielt hast (Kästchen hat eine deckende Farbe (1)), wie viele Münzen du hast (2) (diese kannst du nutzen um Booster zu kaufen). Im Menü (3) kannst du diese Instruktionen jederzeit erneut durchlesen, solltest du etwas vergessen haben. '''),
          const SizedBox(width: 10, height: 20),
          darkPatternsState is DarkPatternsActivatedState
              ? const Image(image: AssetImage('assets/instructions/ins_5.png'), fit: BoxFit.cover)
              : const Image(
                  image: AssetImage('assets/instructions/ins_5_alt.png'), fit: BoxFit.cover),
          const SizedBox(width: 10, height: 20),
          const Text(
              '''Im Rahmen der Pilotstudie hast du außerdem auf dem Startbildschirm im Menü rechts oben einen Punkt „Feedback“. Nutze diesen bitte, sollte dir im Rahmen der Pilotstudie eine Störung oder irgendetwas anderes auffallen, dass dein Spielerlebnis behindert oder beeinflusst. Danke!'''),
          const SizedBox(width: 10, height: 20),
          const Text("Tipps und Tricks: ", style: TextStyle(fontWeight: FontWeight.bold)),
          const Padding(
              padding: EdgeInsets.only(left: 20.0), // Adjust the value for the desired indent
              child: Text('''
•	Plane deine Züge voraus, um die effektivsten Kombinationen zu erstellen.
•	Nutze die speziellen Jellies strategisch, um schwierige Bereiche zu meistern.
•	Halte Ausschau nach unerwarteten Kettenreaktionen.
''')),
          const Text('''Viel Spaß beim Spielen!
          ''', style: TextStyle(fontWeight: FontWeight.bold)),
          ElevatedButton(
              child: const Text('Spiel jetzt starten', textAlign: TextAlign.center), //
              onPressed: () {
                Navigator.pop(context);
              }),
        ]));
  }

  Future<void> getNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authorizationStatus.text = (prefs.getString('notificationSettings') ?? 'notSet');
  }
}
