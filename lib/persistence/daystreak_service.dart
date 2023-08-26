import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DayStreakService {
  static const String lastLogin = 'last_login';
  static const String dayStreak = 'day_streak';

  static Future<int> enhanceDaystreakIfNotAlreadyToday() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime? lastLoginDateTime = await _getLastLogin();
    if (lastLoginDateTime == null || !_alreadyLoggedInToday(lastLoginDateTime)) {
      int currentDayStreak = prefs.get(DayStreakService.dayStreak) as int;
      prefs.setInt(DayStreakService.dayStreak, ++currentDayStreak);
    }
    prefs.setString(DayStreakService.lastLogin, DateUtils.dateOnly(DateTime.now()).toString());

    return prefs.get(DayStreakService.dayStreak) as int;
  }

  static Future<int?> verifyAndGetDayStreak() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime? lastLogin = await _getLastLogin();
    if (lastLogin == null || _shouldDayStreakBeReset(lastLogin)) {
      _resetDayStreak(prefs);
    }
    return prefs.getInt(DayStreakService.dayStreak);
  }

  static void _resetDayStreak(SharedPreferences prefs) {
    prefs.setInt(DayStreakService.dayStreak, 0);
  }

  static bool _shouldDayStreakBeReset(DateTime lastLoginDateTime) {
    return lastLoginDateTime
        .isBefore(DateUtils.dateOnly(DateTime.now()).subtract(const Duration(days: 1)));
  }

  static bool _alreadyLoggedInToday(DateTime lastLoginDateTime) {
    return lastLoginDateTime.isAtSameMomentAs(DateUtils.dateOnly(DateTime.now()));
  }

  static Future<DateTime?> _getLastLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastLogin = prefs.get(DayStreakService.lastLogin) as String?;
    DateTime? lastLoginDateTime;
    if (lastLogin != null) {
      lastLoginDateTime = DateUtils.dateOnly(DateTime.parse(lastLogin));
    }
    if (lastLogin == null || _shouldDayStreakBeReset(lastLoginDateTime!)) {
      _resetDayStreak(prefs);
    }
    return lastLoginDateTime;
  }
}
