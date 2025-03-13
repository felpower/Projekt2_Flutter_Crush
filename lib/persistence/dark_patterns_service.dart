import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/user_state_bloc/coins_bloc/coin_bloc.dart';
import '../bloc/user_state_bloc/coins_bloc/coin_event.dart';

class DarkPatternsService {
  static const String darkPatterns = 'darkPatterns';
  static int darkPatternsValue = 1;

  static Future<int> shouldDarkPatternsBeVisible() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? shouldDarkPatternsBeVisible = prefs.getInt(darkPatterns);
    if (shouldDarkPatternsBeVisible == null) {
      shouldDarkPatternsBeVisible = darkPatternsValue;
      prefs.setInt(darkPatterns, shouldDarkPatternsBeVisible);
    }
    return shouldDarkPatternsBeVisible;
  }

  static Future<void> getDarkPatternReward(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: const Text('Das war gerade ein Dark Pattern!'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Für das finden eines Dark Patterns erhältst du 500 Coins!'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    flutter_bloc.BlocProvider.of<CoinBloc>(context).add(AddCoinsEvent(500));
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
