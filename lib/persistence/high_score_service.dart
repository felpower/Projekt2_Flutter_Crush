import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';

class HighScoreService {
  static const String highScore = 'notSet';
  static const String updateHighScore = 'updateHighScore';
  static String initialHighScore = User.encode([
    User(place: 0, name: 'Jolly', xp: 11, isUser: false),
    User(place: 0, name: 'Du', xp: 0, isUser: true),
    User(place: 0, name: 'andy84', xp: 10, isUser: false),
    User(place: 0, name: 'Spieler04', xp: 9, isUser: false),
    User(place: 0, name: 'game_her0', xp: 8, isUser: false),
    User(place: 0, name: 'flutter_pro', xp: 7, isUser: false),
    User(place: 0, name: 'lilly_92', xp: 5, isUser: false),
    User(place: 0, name: 'LisaZ', xp: 4, isUser: false),
    User(place: 0, name: 'Steffi_3', xp: 3, isUser: false),
    User(place: 0, name: 'Nin4_j', xp: 2, isUser: false),
  ]);

  HighScoreService._privateConstructor();

  static final HighScoreService instance = HighScoreService._privateConstructor();

  static Future<String> getHighScore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentHighScore = prefs.getString(highScore);
    if (currentHighScore == null) {
      prefs.setString(highScore, initialHighScore);
      currentHighScore = initialHighScore;
    }
    String? currentUpdate = prefs.getString(updateHighScore);
    var dateTime = DateTime.now();
    if (currentUpdate == null) {
      prefs.setString(updateHighScore, dateTime.toString());
      currentUpdate = updateHighScore;
    }
    return currentHighScore;
  }
}
