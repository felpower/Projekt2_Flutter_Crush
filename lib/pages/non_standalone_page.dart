import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:pwa_install/pwa_install.dart';

import '../helpers/device_helper.dart';

class NonStandalonePage extends StatefulWidget {
  const NonStandalonePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NonStandalonePageState();
}

class _NonStandalonePageState extends State<NonStandalonePage> {
  late bool isIosDevice;

  @override
  void initState() {
    super.initState();
    isIosDevice = DeviceHelper.isIOSDevice();
  }

  String? error;

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return MaterialApp(
        title: "Herzlich Willkommen",
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.light(),
        themeMode: ThemeMode.light,
        home: Scaffold(
            body: Center(
                child: ListView(padding: const EdgeInsets.all(20), children: [
          const Image(
              image: AssetImage('assets/instructions/ak_uni_logo.png'),
              fit: BoxFit.cover),
          const Text('Um das Spiel spielen zu können',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  decoration: TextDecoration.none)),
          const Text(
              ' fügen Sie bitte jetzt diese Seite auf Ihrem Smartphone ODER Tablet (nicht'
              ' beides!) auf Ihren Homescreen/Startbildschirm hinzu',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  decoration: TextDecoration.none)),
          if (PWAInstall().installPromptEnabled)
            ElevatedButton(
                onPressed: () {
                  try {
                    PWAInstall().promptInstall_();
                  } catch (e) {
                    setState(() {
                      error = e.toString();
                    });
                  }
                },
                child: const Text('Installieren')),
          isIosDevice
              ? const Text('''

Sollte diese Anleitung nicht Ihrer Darstellung entsprechen müssen Sie den Link kopieren und in Safari (Standardbrowser IOS) einfügen.          

Drücken Sie auf den „Teilen“-Button (kleine Viereck mit dem Pfeil nach oben) -> Option -> zum Home-Bildschirm

Beim ersten Öffnen der App werden Sie gefragt, ob diese Ihnen Pushnachrichten senden darf. Bitte klicken Sie hier auf „Erlauben“. Dies ist wichtig für den vollen Funktionsumfang des Spiels!
''',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      decoration: TextDecoration.none))
              : Container(),
          const Text('''
Im Anschluss können Sie die Seite bzw. das Spiel wie jede gewöhnliche App handhaben.''',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  decoration: TextDecoration.none)),
          !isIosDevice
              ? const Text('''
                  
Die Installation funktioniert je nach Smartphone wie in Option 1 oder Option 2 beschrieben (siehe unten).
                  
Unabhängig davon werden Sie beim ersten Öffnen der App gefragt, ob diese Ihnen Pushnachrichten senden darf. Bitte klicken Sie hier auf „Zulassen“. Dies ist wichtig für den vollen Funktionsumfang des Spiels!''',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      decoration: TextDecoration.none))
              : Container(),
          const SizedBox(height: 20),
          !isIosDevice
              ? const Text('Option 1',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      decoration: TextDecoration.none))
              : Container(),
          !isIosDevice
              ? const Text(
                  'Drücken Sie auf die drei kleinen Punkte rechts oben auf dem Bildschirm   anschließend im Menü auf „App installieren“ (siehe Bilder)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      decoration: TextDecoration.none))
              : Container(),
          isIosDevice
              ? const Image(
                  image: AssetImage('assets/instructions/installios.png'),
                  fit: BoxFit.cover)
              : const Image(
                  image: AssetImage('assets/instructions/InstallAndroid.png'),
                  fit: BoxFit.cover),
          !isIosDevice
              ? const Text('Option 2',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      decoration: TextDecoration.none))
              : Container(),
          !isIosDevice
              ? const Text(
                  'Drücken Sie auf die drei Linien rechts unten auf dem Bildschirm  anschließend im Menü auf "Seite Hinzufügen" / "Add page to" --> "Homescreen"/"Startbildschirm" (siehe Bilder)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      decoration: TextDecoration.none))
              : Container(),
          !isIosDevice
              ? const Image(
                  image:
                      AssetImage('assets/instructions/InstallAndroid_alt1.png'),
                  fit: BoxFit.cover)
              : Container(),
          !isIosDevice
              ? const Image(
                  image:
                      AssetImage('assets/instructions/InstallAndroid_alt2.png'),
                  fit: BoxFit.cover)
              : Container(),
        ]))));
  }
}
