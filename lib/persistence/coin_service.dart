import 'package:shared_preferences/shared_preferences.dart';

class CoinService {

  static const String coin = 'coin';
  static const int initialCoins = 100000;//ToDo: Change back to 1000

  static Future<int> addCoins(int amount) async {
    int currentCoins = await getCoins();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int updatedAmount = currentCoins + amount;
    prefs.setInt(coin, updatedAmount);
    return updatedAmount;
  }

  static Future<int> removeCoins(int amount) {
    return addCoins(-amount);
  }

  static Future<int> getCoins() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? coins = prefs.getInt(coin);
    if (coins == null) {
      prefs.setInt(coin, initialCoins);
      coins = initialCoins;
    }
    return coins;


  }
}