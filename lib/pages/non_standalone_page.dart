import 'package:universal_html/html.dart';

import 'package:flutter/material.dart';
import 'package:pwa_install/pwa_install.dart';

class NonStandalonePage extends StatefulWidget {
  const NonStandalonePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BeforeInstallPrompt();
}

class _BeforeInstallPrompt extends State<NonStandalonePage> {
  BeforeInstallPromptEvent? deferredPrompt;

  @override
  void initState() {
    window.addEventListener('beforeinstallprompt', (e) {
      e.preventDefault();
      setState(() {
        deferredPrompt = e as BeforeInstallPromptEvent;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "JellyFun",
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
                child: ListView(padding: const EdgeInsets.all(20), children: [
          const Text(
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
          const Image(
              image: AssetImage('assets/instructions/InstallAppAndroid.jpg'), fit: BoxFit.cover),
          const Text(
            'für Apple (iPhone): Drücken Sie auf den „Teilen“-Button (kleines Viereck mit '
            'dem Pfeil nach oben) -> Option -> zum Home-Bildschirm',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                backgroundColor: Colors.white,
                decoration: TextDecoration.none),
          ),
          Visibility(
              visible: false,
              child: ListTile(
                leading: const Icon(Icons.token),
                title: const Text('Installieren'),
                onTap: () {
                  PWAInstall().promptInstall_();
                },
              )),
          Visibility(
              visible: false,
              child: ElevatedButton(
                onPressed: () async {
                  await _showPrompt();
                },
                child: const Text('Install'),
              )),
        ]))));
  }

  _showPrompt() async {
    await deferredPrompt?.prompt();
    await deferredPrompt?.userChoice;
    setState(() {
      deferredPrompt = null;
    });
  }
}
