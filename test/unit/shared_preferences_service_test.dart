import 'package:bachelor_flutter_crush/persistence/daystreak_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  test(
      'Given shared preferences with current date'
      'When day streak is updated'
      'Then day streak should be unchanged', () async {
    _givenSharedPreferenceMockWithInitialValues(3, DateTime.now().toString());

    final result = await DayStreakService.enhanceDaystreakIfNotAlreadyToday();
    expect(result, 3);
  });

  test(
      'Given shared preferences with date longer than one day ago'
      'When day streak is updated'
      'Then day streak should be returned ', () async {
    _givenSharedPreferenceMockWithInitialValues(
        5, DateTime.now().subtract(const Duration(days: 2)).toString());
    final result = await DayStreakService.enhanceDaystreakIfNotAlreadyToday();
    expect(result, 1);
  });

  test(
      'Given shared preferences with last login one day ago'
      'When day streak is updated'
      'Then day streak should be increased and new date should be set',
      () async {
    _givenSharedPreferenceMockWithInitialValues(
        1, DateTime.now().subtract(const Duration(days: 1)).toString());
    final result = await DayStreakService.enhanceDaystreakIfNotAlreadyToday();
    expect(result, 2);
  });
}

void _givenSharedPreferenceMockWithInitialValues(
    int dayStreak, String lastLogin) {
  Map<String, Object> values = <String, Object>{
    DayStreakService.dayStreak: dayStreak,
    DayStreakService.lastLogin: lastLogin
  };
  SharedPreferences.setMockInitialValues(values);
}
