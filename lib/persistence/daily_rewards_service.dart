import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';

class DailyRewardsService {
  static List<Map<String, dynamic>> rewardsWithXP = [
    {'tag': 1, 'amount': 1, 'type': 'Sonderjelly bunt'},
    {'tag': 2, 'amount': 30, 'type': '\$'},
    {'tag': 3, 'amount': 40, 'type': '\$'},
    {'tag': 4, 'amount': 30, 'type': 'XP'},
    {'tag': 5, 'amount': 1, 'type': 'Sonderjelly gestreift'},
    {'tag': 6, 'amount': 35, 'type': 'XP'},
    {'tag': 7, 'amount': 1, 'type': 'Sonderjelly gestreift'},
    {'tag': 8, 'amount': 100, 'type': '\$'},
    {'tag': 9, 'amount': 30, 'type': '\$'},
    {'tag': 10, 'amount': 20, 'type': 'XP'},
    {'tag': 11, 'amount': 1, 'type': 'Sonderjelly bunt'},
    {'tag': 12, 'amount': 40, 'type': '\$'},
    {'tag': 13, 'amount': 30, 'type': 'XP'},
    {'tag': 14, 'amount': 1, 'type': 'Sonderjelly gestreift'},
    {'tag': 15, 'amount': 50, 'type': '\$'},
    {'tag': 16, 'amount': 1, 'type': 'Sonderjelly bunt'},
    {'tag': 17, 'amount': 100, 'type': '\$'},
    {'tag': 18, 'amount': 30, 'type': '\$'},
    {'tag': 19, 'amount': 45, 'type': 'XP'},
    {'tag': 20, 'amount': 20, 'type': 'XP'},
    {'tag': 21, 'amount': 2, 'type': 'Sonderjelly gestreift'},
    {'tag': 22, 'amount': 50, 'type': 'XP'},
    {'tag': 23, 'amount': 30, 'type': '\$'},
    {'tag': 24, 'amount': 2, 'type': 'Sonderjelly gestreift'},
    {'tag': 25, 'amount': 30, 'type': 'XP'},
    {'tag': 26, 'amount': 40, 'type': 'XP'},
    {'tag': 27, 'amount': 20, 'type': '\$'},
    {'tag': 28, 'amount': 2, 'type': 'Sonderjelly bunt'},
    {'tag': 29, 'amount': 30, 'type': 'XP'},
    {'tag': 30, 'amount': 200, 'type': '\$'},
  ];

  static List<Map<String, dynamic>> rewardsWithoutXP = [
    {'tag': 1, 'amount': 1, 'type': 'Sonderjelly bunt'},
    {'tag': 2, 'amount': 30, 'type': '\$'},
    {'tag': 3, 'amount': 40, 'type': '\$'},
    {'tag': 4, 'amount': 30, 'type': '\$'},
    {'tag': 5, 'amount': 1, 'type': 'Sonderjelly gestreift'},
    {'tag': 6, 'amount': 35, 'type': '\$'},
    {'tag': 7, 'amount': 1, 'type': 'Sonderjelly gestreift'},
    {'tag': 8, 'amount': 100, 'type': '\$'},
    {'tag': 9, 'amount': 30, 'type': '\$'},
    {'tag': 10, 'amount': 20, 'type': '\$'},
    {'tag': 11, 'amount': 1, 'type': 'Sonderjelly bunt'},
    {'tag': 12, 'amount': 40, 'type': '\$'},
    {'tag': 13, 'amount': 30, 'type': '\$'},
    {'tag': 14, 'amount': 1, 'type': 'Sonderjelly gestreift'},
    {'tag': 15, 'amount': 50, 'type': '\$'},
    {'tag': 16, 'amount': 1, 'type': 'Sonderjelly bunt'},
    {'tag': 17, 'amount': 100, 'type': '\$'},
    {'tag': 18, 'amount': 30, 'type': '\$'},
    {'tag': 19, 'amount': 45, 'type': '\$'},
    {'tag': 20, 'amount': 20, 'type': '\$'},
    {'tag': 21, 'amount': 2, 'type': 'Sonderjelly gestreift'},
    {'tag': 22, 'amount': 50, 'type': '\$'},
    {'tag': 23, 'amount': 30, 'type': '\$'},
    {'tag': 24, 'amount': 2, 'type': 'Sonderjelly gestreift'},
    {'tag': 25, 'amount': 30, 'type': '\$'},
    {'tag': 26, 'amount': 40, 'type': '\$'},
    {'tag': 27, 'amount': 20, 'type': '\$'},
    {'tag': 28, 'amount': 2, 'type': 'Sonderjelly bunt'},
    {'tag': 29, 'amount': 30, 'type': '\$'},
    {'tag': 30, 'amount': 200, 'type': '\$'},
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
