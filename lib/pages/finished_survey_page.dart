import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinishedSurveyPage extends StatelessWidget {
  const FinishedSurveyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    checkSharedPreferences();
    return PopScope(
        canPop: true, //ToDo: change to false
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true, //ToDo: change to false
              title: const Text('Vielen Dank für Ihre Teilnahme! '),
            ),
            body: const Text(
                "Diese Studie diente dem Erfassen von natürlichem Spielverhalten bei Handy/Tabletspielen und dem Einfluss sogenannter Dark Patterns. Unter Dark Patterns versteht man Features/Eigenschaften des Spiels, die dazu dienen sollen, den Spieler zu häufigerem oder längerem Spielen zu animieren oder Geld für oder im Spiel auszugeben. Mit deiner Teilnahme leistest du einen wichtigen Beitrag dazu, den Einfluss solcher Dark Patterns noch genauer zu verstehen. Damit können Spieler in Zukunft besser über deren Auswirkungen aufgeklärt und das Spielen solcher Spiele sicherer gestaltet werden.")));
  }

  void checkSharedPreferences() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool("endSurvey", true);
  }
}
