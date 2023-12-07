import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DarkPatternsService {
  static const String darkPatterns = 'darkPatterns';
  static int darkPatternsRandomValue = Random().nextInt(2);
  //ToDo set next int to 7 before release for all dark patterns to be randomly displayed

  static Future<int> shouldDarkPatternsBeVisible() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? shouldDarkPatternsBeVisible = prefs.getInt(darkPatterns);
    if (shouldDarkPatternsBeVisible == null) {
      shouldDarkPatternsBeVisible = 1;//ToDo: Change Before Release!!! darkPatternsRandomValue;
      prefs.setInt(darkPatterns, shouldDarkPatternsBeVisible);
    }
    return shouldDarkPatternsBeVisible;
  }
}
