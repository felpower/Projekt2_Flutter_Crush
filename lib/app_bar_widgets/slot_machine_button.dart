import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/flutter_fortune_wheel/spinner_page.dart';

class SlotMachineButton extends StatelessWidget {
  const SlotMachineButton({Key? key}) : super(key: key);

  static bool addsActive = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DarkPatternsBloc, DarkPatternsState>(
        builder: (context, state) {
      if (state is DarkPatternsActivatedState) {
        return startFortuneWheel(context);
      } else {
        return Container();
      }
    });
  }

  startFortuneWheel(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 0),
        child: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  const FortuneWheel()));
            },
            icon: const Icon(Icons.gamepad_outlined)));
  }
}
