import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinishedSurveyPage extends StatelessWidget {
  const FinishedSurveyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    checkSharedPreferences();
    return PopScope(
        canPop: false,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Vielen Dank für Ihre Teilnahme! '),
            ),
            body: const Column(
              children: [
                Text('''
Diese Studie diente dem Erfassen von natürlichem Spielverhalten bei Handy/Tabletspielen und dem Einfluss sogenannter Dark Patterns. Unter Dark Patterns versteht man Features/Eigenschaften des Spiels, die dazu dienen sollen, Spieler:innen zu häufigerem oder längerem Spielen zu animieren oder Geld für oder im Spiel auszugeben. Mit Ihrer Teilnahme leisten Sie einen wichtigen Beitrag dazu, den Einfluss solcher Dark Patterns noch genauer zu verstehen. Damit können Spieler:innen in Zukunft besser über deren Auswirkungen aufgeklärt und das Spielen solcher Spiele sicherer gestaltet werden.
                ''', textAlign: TextAlign.center),
                Text('''Universität Wien''', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                Text('''
Floragasse 7, 5. Stock, 1040 Wien
office@sba-research.org
+43 (1) 505 36 88''', textAlign: TextAlign.center),
                SizedBox(height: 20),
                Text('''Kammer für Arbeiter und Angestellte für Niederösterreich''',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                Text('''
AK-Platz 1, 3100 St. Pölten
jellyfun@aknoe.at
+43 5 7171-0''', textAlign: TextAlign.center),
              ],
            )));
  }

  void checkSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("endSurvey", DateTime.now().toString());
  }
}
