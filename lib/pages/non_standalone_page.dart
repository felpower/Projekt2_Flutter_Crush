import 'package:flutter/material.dart';
import 'package:universal_html/html.dart';

import '../helpers/device_helper.dart';

class NonStandalonePage extends StatefulWidget {
  const NonStandalonePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BeforeInstallPrompt();
}

class _BeforeInstallPrompt extends State<NonStandalonePage> {
  BeforeInstallPromptEvent? deferredPrompt;

  bool isIosDevice = DeviceHelper.isIOSDevice();

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
        title: "Herzlich Willkommen zur Studie",
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
                child: ListView(padding: const EdgeInsets.all(20), children: [
          isIosDevice
              ? const Text(
                  'Um mit der Studie teilnehmen zu können fügen Sie bitte jetzt diese Seite auf Ihren Homescreen/Startbildschirm hinzu. '
                  'Im Anschluss können Sie die Seite bzw. das Spiel wie jede gewöhnliche App handhaben. Die Installation funktionier wie folgt (siehe auch Bild):'
                  'Drücken Sie auf den „Teilen“-Button (kleine Viereck mit dem Pfeil nach '
                  'oben)   Option  zum Home-Bildschirm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      decoration: TextDecoration.none))
              : const Text(
                  'Um mit der Studie teilnehmen zu können fügen Sie bitte jetzt diese Seite auf Ihren Homescreen/Startbildschirm hinzu. Im Anschluss können Sie die Seite bzw. das Spiel wie jede gewöhnliche App handhaben. Die Installation funktionier wie folgt (siehe auch Bild):'
                  ' Drücken Sie auf die drei kleinen Punkte rechts oben auf dem Bildschirm  App Installieren',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      decoration: TextDecoration.none)),
          isIosDevice
              ? const Image(
                  image: AssetImage('assets/instructions/InstallIos.png'), fit: BoxFit.cover)
              : const Image(
                  image: AssetImage('assets/instructions/InstallAndroid.png'), fit: BoxFit.cover)
        ]))));
  }
}
