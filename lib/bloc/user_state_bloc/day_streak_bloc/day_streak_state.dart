abstract class DayStreakState {
  int dayStreak;

  DayStreakState(this.dayStreak);
}

class CurrentDayStreakState extends DayStreakState {
  CurrentDayStreakState(int dayStreak) : super(dayStreak);
}

class DayStreakMilestoneState extends DayStreakState {
  final int addedCoins;

  DayStreakMilestoneState(int dayStreak, this.addedCoins) : super(dayStreak);
}
