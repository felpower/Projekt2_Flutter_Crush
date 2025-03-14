import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'info_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
            body: Column(
          children: [
            Expanded(
              child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Image(
                            image:
                                AssetImage('assets/instructions/welcome_1.png'),
                            fit: BoxFit.cover),
                        ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut);
                            },
                            child: const Text("Weiter"))
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Image(
                            image:
                                AssetImage('assets/instructions/welcome_2.png'),
                            fit: BoxFit.cover),
                        ElevatedButton(
                            onPressed: () {
                              setFirstStart();
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DeviceToken()));
                            },
                            child: const Text("Spiel Starten"))
                      ],
                    )
                  ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${_currentPage + 1} / 2'),
              ],
            ),
          ],
        )));
  }

  void setFirstStart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var now = DateTime.now();
    prefs.setBool("firstStart", false);
    prefs.setString("firstStartTime", now.toString());
  }
}
