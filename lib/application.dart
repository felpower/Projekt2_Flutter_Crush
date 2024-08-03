// ignore_for_file: avoid_print

import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/coins_bloc/coin_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/level_bloc/level_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_bloc.dart';
import 'package:bachelor_flutter_crush/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;

import 'bloc/bloc_provider.dart' as custom_bloc;
import 'bloc/game_bloc.dart';
import 'bloc/user_state_bloc/high_score_bloc/high_score_bloc.dart';
import 'controllers/audio_manager.dart';

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return custom_bloc.BlocProvider<AudioManager>(
      bloc: AudioManager(),
      child: custom_bloc.BlocProvider<GameBloc>(
        bloc: GameBloc(),
        child: flutter_bloc.MultiBlocProvider(
          providers: _getBlocs(context),
          child: MaterialApp(
            title: 'JellyFun',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.light(),
            themeMode: ThemeMode.light,
            home: const HomePage(),
            // routes: {
            //   '/startSurvey': (context) => const SurveyPage(title: "Start"),
            //   '/endSurvey': (context) => const SurveyPage(title: "End"),
            // },
          ),
        ),
      ),
    );
  }

  List<flutter_bloc.BlocProvider> _getBlocs(BuildContext context) {
    return [
      flutter_bloc.BlocProvider<CoinBloc>(
          create: (context) => CoinBloc(custom_bloc.BlocProvider.of<GameBloc>(context))),
      flutter_bloc.BlocProvider<XpBloc>(
          create: (context) => XpBloc(custom_bloc.BlocProvider.of<GameBloc>(context))),
      flutter_bloc.BlocProvider<HighScoreBloc>(create: (context) => HighScoreBloc()),
      flutter_bloc.BlocProvider<LevelBloc>(
          create: (context) => LevelBloc(flutter_bloc.BlocProvider.of<XpBloc>(context))),
      flutter_bloc.BlocProvider<ReportingBloc>(create: (context) => ReportingBloc()),
      flutter_bloc.BlocProvider<DarkPatternsBloc>(create: (context) => DarkPatternsBloc())
    ];
  }
}