import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartPageNavigationButton extends StatelessWidget {
  const StartPageNavigationButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DarkPatternsBloc, DarkPatternsState>(builder: (context, state) {
      if (state is DarkPatternsActivatedState) {
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  "/start",
                );
              },
              icon: const Icon(Icons.insert_drive_file_outlined)),
        );
      } else {
        return Container();
      }
    });
  }
}
