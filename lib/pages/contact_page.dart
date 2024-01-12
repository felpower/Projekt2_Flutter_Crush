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
              title: const Text('Kontaktinformationen'),
            ),
            body: const Center(
                child: SingleChildScrollView(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('''Arbeiterkammer Niederösterreich''',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('''E-Mail: jellyfun@aknoe.at'''),
                  Text('''Universität Wien''', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('''Contact
Office: Floragasse 7, 5th Floor, 1040 Wien
Phone: +43 (1) 505 36 88
Fax: +43(1) 505 88 88
E-Mail: office@sba-research.org''', textAlign: TextAlign.center),
                ],
              ),
            ))));
  }
}
