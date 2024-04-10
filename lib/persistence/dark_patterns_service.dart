import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DarkPatternsService {
  static const String darkPatterns = 'darkPatterns';
  static int darkPatternsValue = 3;

  static Future<int> shouldDarkPatternsBeVisible() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? shouldDarkPatternsBeVisible = prefs.getInt(darkPatterns);
    if (shouldDarkPatternsBeVisible == null) {
      shouldDarkPatternsBeVisible = darkPatternsValue;
      prefs.setInt(darkPatterns, shouldDarkPatternsBeVisible);
    }
    return shouldDarkPatternsBeVisible;
  }
}
