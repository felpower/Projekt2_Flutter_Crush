import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DarkPatternsService {
  static const String darkPatterns = 'darkPatterns';
  static bool darkPatternsRandomValue = Random().nextInt(2) == 0 ? false : true;

  static Future<bool> shouldDarkPatternsBeVisible() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? shouldDarkPatternsBeVisible = prefs.getBool(darkPatterns);
    if (shouldDarkPatternsBeVisible == null) {
      shouldDarkPatternsBeVisible = true; //FixMe: darkPatternsRandomValue;
      prefs.setBool(darkPatterns, shouldDarkPatternsBeVisible);
    }
    return shouldDarkPatternsBeVisible;
  }
}
