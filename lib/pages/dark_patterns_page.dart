import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkPatternsPage extends StatefulWidget {
  const DarkPatternsPage({Key? key}) : super(key: key);

  @override
  DarkPatternsPageState createState() => DarkPatternsPageState();
}

class DarkPatternsPageState extends State<DarkPatternsPage> {
  Map<String, bool> darkPatterns = {};
  bool notificationsActivated = false;

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
      darkPatterns = {
        'Notification': notificationsActivated &&
            (prefs.getBool('darkPatternsInfoNotification') ?? false),
        'Variable Rewards': prefs.getBool('darkPatternsInfoVAR') ?? false,
        'High-Score': prefs.getBool('darkPatternsInfoScore') ?? false,
        'Shop': prefs.getBool('darkPatternsInfoShop') ?? false,
        'Fear of Missing Out': prefs.getBool('darkPatternsInfoFoMo') ?? false,
        'Werbung': prefs.getBool('darkPatternsInfoAdds') ?? false,
        'Complete the Collection':
            prefs.getBool('darkPatternsInfoCompleted') ?? false,
      };
    });
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Dark Patterns gefunden'),
              leading: BackButton(
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Stack(children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/background/background_new.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ListView(
                children: darkPatterns.entries.map((entry) {
                  bool isNotification = entry.key == 'Notification';
                  return ListTile(
                    title: Text(
                      entry.key,
                      style: TextStyle(
                        color: isNotification && !notificationsActivated
                            ? Colors.grey
                            : Colors.black,
                        decoration: isNotification && !notificationsActivated
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: Icon(
                      entry.value ? Icons.check_circle : Icons.cancel,
                      color: entry.value ? Colors.green : Colors.red,
                    ),
                  );
                }).toList(),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: resetDarkPatterns,
                  child: const Text('Dark Patterns zurücksetzen',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
              if (!notificationsActivated)
                Center(
                  child: ElevatedButton(
                    onPressed: activateNotifications,
                    child: const Text('Activate Notifications'),
                  ),
                ),
            ])));
  }

  void resetDarkPatterns() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkPatternsInfoNotification', false);
    await prefs.setBool('darkPatternsInfoVAR', false);
    await prefs.setBool('darkPatternsInfoScore', false);
    await prefs.setBool('darkPatternsInfoShop', false);
    await prefs.setBool('darkPatternsInfoFoMo', false);
    await prefs.setBool('darkPatternsInfoAdds', false);
    await prefs.setBool('darkPatternsInfoCompleted', false);
    await prefs.setBool('showDarkPatternsInfoText', true);

    setState(() {
      darkPatterns.updateAll((key, value) => false);
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('DarkPatterns zurückgesetzt'),
          content: const Text('Die DarkPatterns wurden zurückgesetzt'),
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
