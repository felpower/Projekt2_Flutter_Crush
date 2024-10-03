import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              title: const Text('Kontaktinformationen',
                  textAlign: TextAlign.center),
              centerTitle: true,
            ),
            body: const Center(
                child: SingleChildScrollView(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('''SBA Research''',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  Text('''
Floragasse 7, 5. Stock, 1040 Wien
office@sba-research.org
+43 (1) 505 36 88''', textAlign: TextAlign.center),
                  SizedBox(height: 20),
                  Text(
                      '''Kammer für Arbeiter und Angestellte für Niederösterreich''',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  Text('''
AK-Platz 1, 3100 St. Pölten
jellyfun@aknoe.at
+43 5 7171-0''', textAlign: TextAlign.center),
                ],
              ),
            ))));
  }
}
