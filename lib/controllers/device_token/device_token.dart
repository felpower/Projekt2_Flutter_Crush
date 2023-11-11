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
          FutureBuilder<String>(
              future: FirebaseMessagingWeb().getToken(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                  text = snapshot.data!;
                  return SelectableText(snapshot.data!);
                }
                return const CircularProgressIndicator();
              }),
          ElevatedButton(
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
          ElevatedButton(
            child: const Text('Token not showing, reload page'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
              child: const Text('Check Push Permission'),
              onPressed: () {
                getNotification();
              }),
          TextField(controller: autohrizationStatus, textAlign: TextAlign.center, readOnly: true),
        ])));
  }

  Future<void> getNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    autohrizationStatus.text = (prefs.getString('notificationSettings') ?? 'notSet');
  }
}
