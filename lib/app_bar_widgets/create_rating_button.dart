import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:bachelor_flutter_crush/pages/rating_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
/*
This Class is not used anymore, kept for future implementations, if wanted to be added again
 */
class CreateRatingButton extends StatelessWidget {
  const CreateRatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DarkPatternsBloc, DarkPatternsState>(
        builder: (context, state) {
      if (state is DarkPatternsActivatedState) {
        return Padding(
          padding: const EdgeInsets.only(right: 5),
          child: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RatingPage()));
              },
              icon: const Icon(Icons.rate_review)),
        );
      } else {
        return Container();
      }
    });
  }
}
