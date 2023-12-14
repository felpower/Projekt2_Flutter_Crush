import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;

import 'package:flutter/material.dart';

class OldVersionPage extends StatelessWidget {
  const OldVersionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Alte Seite",
        theme: ThemeData.light(),
        darkTheme: ThemeData.light(),
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
                child: ListView(padding: const EdgeInsets.all(20), children: [
          const Text(
              'Sie befinden sich noch auf einer alten Version, bitte klicken Sie auf den Button '
              'um alle aktuellen Daten zu löschen und neu zu beginnen.'
                  'Sollte dies nicht der Fall sein und Sie sind sich sicher auf der aktuellen '
                  'Version zu sein, bitte klicken Sie nicht den Button und löschen Sie die Cookies '
                  'nicht. Wir bitten Sie uns zu kontaktieren.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  decoration: TextDecoration.none)),
          Visibility(
            visible: true,
            child: ListTile(
              leading: const Icon(Icons.cookie),
              title: const Text('Clear Cookies'),
              onTap: () {
                js.context.callMethod('clearCookies');
                html.window.localStorage.clear();
                html.window.location.reload();
              },
              tileColor: Colors.grey[200],
              // Background color to make it feel like a button
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)), // Rounded corners
            ),
          ),
        ]))));
  }
}
