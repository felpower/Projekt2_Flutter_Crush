import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GdprBanner extends StatefulWidget {
  @override
  State<GdprBanner> createState() => _GdprBannerState();
}

class _GdprBannerState extends State<GdprBanner> {
  bool isAccepted = false;

  @override
  void initState() {
    super.initState();
    _loadGdprStatus();
  }

  _loadGdprStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isAccepted = prefs.getBool('gdprAccepted') ?? false;
    });
  }

  _acceptGdpr() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gdprAccepted', true);
    setState(() {
      isAccepted = true;
    });
  }

  _declineGdpr() {
    // Handle GDPR decline action here
    // For example, navigate to a different page or close the app
  }

  @override
  Widget build(BuildContext context) {
    if (isAccepted) {
      return Container();
    } else {
      return Container(
        color: Colors.grey[200],
        child: Column(
          children: <Widget>[
            const Text(
                'Wir verwenden Cookies, um Ihr Erlebnis zu verbessern. Durch die Nutzung unserer Website stimmen Sie unserer Verwendung von Cookies zu.'),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _acceptGdpr,
                    child: const Text('Akzeptieren'),
                  ),
                  ElevatedButton(
                    onPressed: _declineGdpr,
                    child: const Text('Ablehnen'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
