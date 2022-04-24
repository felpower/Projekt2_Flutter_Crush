import 'package:bachelor_flutter_crush/bloc/game_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/coins_bloc/coin_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../persistence/daystreak_service.dart';
import '../coins_bloc/coin_bloc.dart';
import 'day_streak_event.dart';
import 'day_streak_state.dart';

class DayStreakBloc extends Bloc<DayStreakEvent, DayStreakState> {
  static const List<int> dayStreakMilestones = [1, 3, 5, 10, 15, 20, 25, 30];

  final CoinBloc coinBloc;

  DayStreakBloc(GameBloc gameBloc, this.coinBloc)
      : super(CurrentDayStreakState(0)) {
    on<UpdateDayStreakEvent>(_onUpdateDayStreak);
    on<LoadDayStreakEvent>(_onLoadDayStreak);
    add(LoadDayStreakEvent());
    gameBloc.gameIsOver.listen(_onGameOver);
  }

  void _onLoadDayStreak(
      LoadDayStreakEvent event, Emitter<DayStreakState> emit) async {
    int? updatedDayStreak = await DayStreakService.verifyAndGetDayStreak();
    updatedDayStreak != null
        ? emit(CurrentDayStreakState(updatedDayStreak))
        : emit(CurrentDayStreakState(0));
  }

  void _onUpdateDayStreak(
      UpdateDayStreakEvent event, Emitter<DayStreakState> emit) async {
    int currentDayStreak = state.dayStreak;
    int updatedDayStreak =
        await DayStreakService.enhanceDaystreakIfNotAlreadyToday();
    if (currentDayStreak != updatedDayStreak) {
      if (_milestoneReached(updatedDayStreak)) {
        int coins = 10 * updatedDayStreak;
        await Future.delayed(const Duration(seconds: 4));
        coinBloc.add(AddCoinsEvent(coins));
        emit(DayStreakMilestoneState(updatedDayStreak, coins));
      }
      emit(CurrentDayStreakState(updatedDayStreak));
    }
  }

  bool _milestoneReached(int dayStreak) {
    return dayStreakMilestones.contains(dayStreak);
  }

  void _onGameOver(bool success) {
    if (success) {
      add(UpdateDayStreakEvent());
    }
  }
}
