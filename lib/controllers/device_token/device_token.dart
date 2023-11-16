import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/firebase_messaging.dart';

class DeviceToken extends StatefulWidget {
  const DeviceToken({Key? key}) : super(key: key);

  @override
  State<DeviceToken> createState() => _DeviceTokenState();
}

class _DeviceTokenState extends State<DeviceToken> {
  String text = "";
  TextEditingController autohrizationStatus = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Device Token')),
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
            child: Column(children: [
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
                  FirebaseMessagingWeb.requestPermission();
                }),
          ),
          Visibility(
            visible: false,
            child: TextField(
                controller: autohrizationStatus, textAlign: TextAlign.center, readOnly: true),
          ),
              const Text("Hier wird eine Seite angezeigt, die in Zukunft das Spiel erklären wird"),
              ElevatedButton(
                  child: const Text('Continue to Start'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
        ])));
  }

  Future<void> getNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    autohrizationStatus.text = (prefs.getString('notificationSettings') ?? 'notSet');
  }
}
