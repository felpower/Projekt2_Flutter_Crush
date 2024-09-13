import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkPatternsPage extends StatefulWidget {
  const DarkPatternsPage({Key? key}) : super(key: key);

  @override
  DarkPatternsPageState createState() => DarkPatternsPageState();
}

class DarkPatternsPageState extends State<DarkPatternsPage> {
  Map<String, bool> darkPatterns = {};

  @override
  void initState() {
    super.initState();
    getDarkPatternsInfos();
  }

  void getDarkPatternsInfos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      darkPatterns = {
        'Notification': prefs.getBool('darkPatternsInfoNotification') ?? false,
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
                  return ListTile(
                    title: Text(entry.key),
                    trailing: Icon(
                      entry.value ? Icons.check_circle : Icons.cancel,
                      color: entry.value ? Colors.green : Colors.red,
                    ),
                  );
                }).toList(),
              ),
            ])));
  }
}
