import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';

class DailyRewardsService {
  static List<Map<String, dynamic>> rewardsWithXP = [
    {'tag': 1, 'amount': 2, 'type': 'Sonderjellies bunt'},
    {'tag': 2, 'amount': 3, 'type': 'Sonderjellies gestreift'},
    {'tag': 3, 'amount': 200, 'type': '\$'},
    {'tag': 4, 'amount': 100, 'type': 'XP'},
    {'tag': 5, 'amount': 2, 'type': 'Sonderjellies gestreift'},
    {'tag': 6, 'amount': 200, 'type': 'XP'},
    {'tag': 7, 'amount': 1, 'type': 'Sonderjelly bunt'},
    {'tag': 8, 'amount': 100, 'type': '\$'},
    {'tag': 9, 'amount': 150, 'type': 'XP'},
    {'tag': 10, 'amount': 150, 'type': '\$'},
    {'tag': 11, 'amount': 2, 'type': 'Sonderjellies gestreift'},
    {'tag': 12, 'amount': 200, 'type': 'XP'},
    {'tag': 13, 'amount': 100, 'type': '\$'},
    {'tag': 14, 'amount': 3, 'type': 'Sonderjelly gestreift'},
    {'tag': 15, 'amount': 500, 'type': '\$'},
    {'tag': 16, 'amount': 3, 'type': 'sonderjelly bunt'},
    {'tag': 17, 'amount': 200, 'type': '\$'},
    {'tag': 18, 'amount': 100, 'type': 'XP'},
    {'tag': 19, 'amount': 200, 'type': '\$'},
    {'tag': 20, 'amount': 3, 'type': 'sonderjellies gestreift'},
    {'tag': 21, 'amount': 100, 'type': 'XP'},
    {'tag': 22, 'amount': 150, 'type': '\$'},
    {'tag': 23, 'amount': 2, 'type': 'sonderjellies bunt'},
    {'tag': 24, 'amount': 150, 'type': 'XP'},
    {'tag': 25, 'amount': 200, 'type': '\$'},
    {'tag': 26, 'amount': 200, 'type': 'XP'},
    {'tag': 27, 'amount': 4, 'type': 'sonderjellies gestreift'},
    {'tag': 28, 'amount': 500, 'type': '\$'},
    {'tag': 29, 'amount': 100, 'type': 'XP'},
    {'tag': 30, 'amount': 1, 'type': 'Sonderjelly bunt'}
  ];

  static List<Map<String, dynamic>> rewardsWithoutXP = [
    {'tag': 1, 'amount': 2, 'type': 'Sonderjellies bunt'},
    {'tag': 2, 'amount': 3, 'type': 'Sonderjellies gestreift'},
    {'tag': 3, 'amount': 200, 'type': '\$'},
    {'tag': 4, 'amount': 100, 'type': '\$'},
    {'tag': 5, 'amount': 2, 'type': 'Sonderjellies gestreift'},
    {'tag': 6, 'amount': 200, 'type': '\$'},
    {'tag': 7, 'amount': 1, 'type': 'Sonderjelly bunt'},
    {'tag': 8, 'amount': 100, 'type': '\$'},
    {'tag': 9, 'amount': 150, 'type': '\$'},
    {'tag': 10, 'amount': 150, 'type': '\$'},
    {'tag': 11, 'amount': 2, 'type': 'Sonderjellies gestreift'},
    {'tag': 12, 'amount': 200, 'type': '\$'},
    {'tag': 13, 'amount': 100, 'type': '\$'},
    {'tag': 14, 'amount': 3, 'type': 'Sonderjelly gestreift'},
    {'tag': 15, 'amount': 500, 'type': '\$'},
    {'tag': 16, 'amount': 3, 'type': 'sonderjelly bunt'},
    {'tag': 17, 'amount': 200, 'type': '\$'},
    {'tag': 18, 'amount': 100, 'type': '\$'},
    {'tag': 19, 'amount': 200, 'type': '\$'},
    {'tag': 20, 'amount': 3, 'type': 'sonderjellies gestreift'},
    {'tag': 21, 'amount': 100, 'type': '\$'},
    {'tag': 22, 'amount': 150, 'type': '\$'},
    {'tag': 23, 'amount': 2, 'type': 'sonderjellies bunt'},
    {'tag': 24, 'amount': 150, 'type': '\$'},
    {'tag': 25, 'amount': 200, 'type': '\$'},
    {'tag': 26, 'amount': 200, 'type': '\$'},
    {'tag': 27, 'amount': 4, 'type': 'sonderjellies gestreift'},
    {'tag': 28, 'amount': 500, 'type': '\$'},
    {'tag': 29, 'amount': 100, 'type': '\$'},
    {'tag': 30, 'amount': 1, 'type': 'Sonderjelly bunt'}
  ];

  static List<Map<String, dynamic>> getRewards(DarkPatternsState darkPatternsState) {
    if (darkPatternsState is DarkPatternsActivatedState) {
      return rewardsWithXP;
    } else {
      return rewardsWithoutXP;
    }
  }

  static Map<String, dynamic> getTodaysReward(int tag, DarkPatternsState darkPatternsState) {
    var foundReward = getRewards(darkPatternsState).firstWhere(
      (reward) => reward['tag'] == tag,
      orElse: () => {'amount': 'Not Found', 'type': 'Not Found'},
    );
    return foundReward;
  }
}
