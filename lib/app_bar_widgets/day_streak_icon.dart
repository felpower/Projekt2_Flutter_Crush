import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/day_streak_bloc/day_streak_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/day_streak_bloc/day_streak_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DayStreakIcon extends StatelessWidget {
  const DayStreakIcon(this.numberOfDays, {Key? key}) : super(key: key);
  final int numberOfDays;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DarkPatternsBloc, DarkPatternsState>(
        builder: (context, state) {
      if (state is DarkPatternsActivatedState) {
        return Padding(
            padding: const EdgeInsets.only(left: 7.5, right: 7.5),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department),
                BlocBuilder<DayStreakBloc, DayStreakState>(
                  builder: (context, state) {
                    return Text(state.dayStreak.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold));
                  },
                )
              ],
            ));
      } else {
        return Container();
      }
    });
  }
}
