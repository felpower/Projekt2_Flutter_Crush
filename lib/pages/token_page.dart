import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/firebase_messaging.dart';

class TokenPage extends StatefulWidget {
  const TokenPage({Key? key}) : super(key: key);

  @override
  State<TokenPage> createState() => TokenPageState();
}

class TokenPageState extends State<TokenPage> {
  late bool notificationsActivated;

  Future<Map<String, String>> _fetchUserData() async {
    String uuid = await FirebaseStore.getUuid();
    String authToken = await FirebaseMessagingWeb.getToken(); // Assuming this method exists
    if (authToken == "No token found, please reload page") {
      authToken = "";
    }
    return {'uuid': uuid, 'authToken': authToken};
  }

  @override
  void initState() {
    super.initState();
    getDarkPatternsInfos();
    activateNotifications();
  }

  void getDarkPatternsInfos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsActivated = prefs.getBool('notificationsActivated') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('User Data')),
      ),
      body: Center(
        child: FutureBuilder<Map<String, String>>(
          future: _fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              print("This is the token${snapshot.data!['authToken']!}");

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'UUID: ${snapshot.data!['uuid']}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: snapshot.data!['uuid']!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('UUID copied to clipboard')),
                      );
                    },
                    child: const Text('Copy UUID'),
                  ),
                  const SizedBox(height: 20),
                  snapshot.data!['authToken'] == ""
                      ? const Center(child: Text('No Auth Token found', textAlign: TextAlign.center))
                      :
                  Center(
                    child: Text(
                      'Auth Token: ${snapshot.data!['authToken']}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (snapshot.data!['authToken'] == "")
                    ElevatedButton(
                      onPressed: activateNotifications,
                      child: const Text('Enable Notifications'),
                    ),
                  if (snapshot.data!['authToken'] != "")
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: snapshot.data!['authToken']!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Auth Token copied to clipboard')),
                        );
                      },
                      child: const Text('Copy Auth Token'),
                    ),
                ],
              );
            } else {
              return const Text('No data found');
            }
          },
        ),
      ),
    );
  }


  void activateNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsActivated', true);
      setState(() {
        notificationsActivated = true;
      });
    } else if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      setState(() {
        notificationsActivated = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Benachrichtigungen blockiert'),
            content: const Text(
                'Du hast die Benachrichtigungen blockiert. Bitte aktiviere sie in den Einstellungen. '
                    'Um alle Dark Patterns zu sehen, müssen die Benachrichtigungen aktiviert sein.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}