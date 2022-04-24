import 'package:shared_preferences/shared_preferences.dart';

class LevelService {
  static const String level = 'level';
  static const int numberOfLevels = 16;

  static addLevel(int levelnumber) async {
    List<int> levels = await getLevels();
    levels.add(levelnumber);
    setLevels(levels);
  }

  static Future<List<int>> getLevels() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? levelList = prefs.getStringList(level);
    if (levelList == null) {
      levelList = ['1'];
      prefs.setStringList(level, levelList);
    }
    return levelList.map((level) => int.parse(level)).toList();
  }

  static void setLevels(List<int> levels) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(level, levels.map((e) => '$e').toList());
  }

  static void updateLevels(int xp) async {
    List<int> levels = await getLevels();
    for (int i = 1; i < numberOfLevels; i++) {
      if (!levels.contains(i) && i * 10 <= xp) {
        levels.add(i);
      }
    }
    setLevels(levels);
  }
}