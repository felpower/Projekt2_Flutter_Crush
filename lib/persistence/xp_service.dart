import 'package:shared_preferences/shared_preferences.dart';

class XpService {
  static const String xp = 'xp';
  static const String doubleXp = 'doubleXpUntil';
  static const String multiplier = 'multiplier';
  static const String currentMultiplier = 'currentMultiplier';
  static const int initialXp = 0;

  XpService._privateConstructor();

  static final XpService instance = XpService._privateConstructor();

  static Future<int> addXp(int amount) async {
    int currentXp = await getXp();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int updatedAmount = currentXp + amount;
    prefs.setInt(xp, updatedAmount);
    return updatedAmount;
  }

  static Future<int> getXp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? currentXp = prefs.getInt(xp);
    if (currentXp == null) {
      prefs.setInt(xp, initialXp);
      currentXp = initialXp;
    }
    return currentXp;
  }

  static Future<void> updateMultiplierXpTime(DateTime activeUntil) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(doubleXp, activeUntil.toString());
  }

  static Future<void> addMultiplier(int n) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? multipliers = prefs.getStringList(multiplier);
    multipliers ??= [];
    multipliers.add(n.toString());
    prefs.setStringList(multiplier, multipliers);
  }

  static Future<void> updateCurrentMultiplier(int n) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(currentMultiplier, n);
  }

  static Future<int> getCurrentMultiplier() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? result = prefs.getInt(currentMultiplier);
    result ??= 1;
    return result;
  }

  static Future<int> popMultiplier(int n) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? multipliers = prefs.getStringList(multiplier);
    if (multipliers != null && multipliers.isNotEmpty) {
      int result = int.parse(multipliers[multipliers.length - 1]);
      multipliers.removeAt(multipliers.length - 1);
      prefs.setStringList(multiplier, multipliers);
      return result;
    } else {
      return 1;
    }
  }

  static Future<bool> isDoubleXpActive() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? doubleXpTime = prefs.getString(doubleXp);
    if (doubleXpTime == null) {
      return false;
    }
    DateTime dateTime = DateTime.parse(doubleXpTime);
    if (dateTime.isAfter(DateTime.now())) {
      return true;
    }
    return false;
  }
}
