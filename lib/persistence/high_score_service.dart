import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';

class HighScoreService {
  static const String highScore = 'highScore';
  static const String updateHighScore = 'updateHighScore';
  static String initialHighScore = User.encode([
    User(place: 0, name: 'Best Player Ever', xp: 0),
    User(place: 0, name: 'Patrick', xp: 0),
    User(place: 0, name: 'Some Random Dude', xp: 10),
    User(place: 0, name: 'Huckleberry Finn', xp: 9),
    User(place: 0, name: 'Star Wars Fan Guy', xp: 7),
    User(place: 0, name: 'League Player', xp: 5),
    User(place: 0, name: 'I am not very good at this', xp: 4),
    User(place: 0, name: 'I do not even know who i am', xp: 3),
    User(place: 0, name: 'The best ever', xp: 1),
  ]);

  HighScoreService._privateConstructor();

  static final HighScoreService instance =
      HighScoreService._privateConstructor();

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
