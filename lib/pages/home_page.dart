import 'dart:async';

import 'package:bachelor_flutter_crush/app_bar_widgets/day_streak_icon.dart';
import 'package:bachelor_flutter_crush/app_bar_widgets/information_page_navigation_button.dart';
import 'package:bachelor_flutter_crush/app_bar_widgets/slot_machine_button.dart';
import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_event.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/day_streak_bloc/day_streak_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/level_bloc/level_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/level_bloc/level_state.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_state.dart';
import 'package:bachelor_flutter_crush/game_widgets/game_level_button.dart';
import 'package:bachelor_flutter_crush/gamification_widgets/daystreak_milestone_reached_splash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;

import '../app_bar_widgets/high_score_page_navigation_button.dart';
import '../app_bar_widgets/remove_adds_button.dart';
import '../bloc/bloc_provider.dart';
import '../bloc/game_bloc.dart';
import '../bloc/user_state_bloc/coins_bloc/coin_bloc.dart';
import '../bloc/user_state_bloc/coins_bloc/coin_state.dart';
import '../bloc/user_state_bloc/day_streak_bloc/day_streak_state.dart';
import '../gamification_widgets/credit_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late StreamSubscription _daystreakMilestoneSubscription;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ReportingBloc _reportingBloc =
        flutter_bloc.BlocProvider.of<ReportingBloc>(context);
    switch (state) {
      case AppLifecycleState.resumed:
        _reportingBloc.add(ReportStartAppEvent(DateTime.now()));
        break;
      case AppLifecycleState.inactive:
        _reportingBloc.add(ReportCloseAppEvent(DateTime.now()));
        break;
      case AppLifecycleState.detached:
        _reportingBloc.add(ReportCloseAppEvent(DateTime.now()));
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..addListener(() {
        setState(() {});
      });

    CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.6,
        1.0,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DarkPatternsBloc darkPatternsBloc =
        flutter_bloc.BlocProvider.of<DarkPatternsBloc>(context);
    _daystreakMilestoneSubscription =
        flutter_bloc.BlocProvider.of<DayStreakBloc>(context)
            .stream
            .listen((state) {
      if (state is DayStreakMilestoneState &&
          darkPatternsBloc.state is DarkPatternsActivatedState) {
        OverlayEntry? _dayStreakMileStoneSplash;
        _dayStreakMileStoneSplash = OverlayEntry(
          builder: (context) {
            return DayStreakMilestoneReachedSplash(
                state.dayStreak, state.addedCoins, () {
              _dayStreakMileStoneSplash?.remove();
            });
          },
        );
        Overlay.of(context).insert(_dayStreakMileStoneSplash);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _daystreakMilestoneSubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DarkPatternsBloc darkPatternsBloc =
        flutter_bloc.BlocProvider.of<DarkPatternsBloc>(context);
    GameBloc gameBloc = BlocProvider.of<GameBloc>(context);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Size screenSize = mediaQueryData.size;
    double webWidth = 500;
    double webHeight = 1000;
    double levelsWidth = -100.0 +
        ((mediaQueryData.orientation == Orientation.portrait)
            ? screenSize.width
            : screenSize.height);
    double creditPanelWidth = kIsWeb ? webWidth / 4 : screenSize.width / 4;

    return Scaffold(
        appBar: AppBar(
          leading: const DayStreakIcon(1),
          title: const Text('Flutter Crush'),
          actions: const <Widget>[
            InformationPageNavigationButton(),
            SlotMachineButton(),
            HighScorePageNavigationButton(),
          ],
        ),
        body: WillPopScope(
          // No way to get back
          onWillPop: () async => false,
          child: Stack(
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage('assets/images/background/background2.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                  heightFactor: 1,
                  child: SizedBox(
                    width: kIsWeb ? webWidth : null,
                    height: kIsWeb ? webHeight : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        flutter_bloc.BlocBuilder<DarkPatternsBloc,
                            DarkPatternsState>(
                          builder: (context, state) {
                            if (state is DarkPatternsActivatedState) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  flutter_bloc.BlocBuilder<XpBloc, XpState>(
                                      builder: (context, state) {
                                    return CreditPanel(
                                        'XP: ' + state.amount.toString(),
                                        30,
                                        creditPanelWidth);
                                  }),
                                  // flutter_bloc.BlocBuilder<HighScoreBloc, HighScoreState>(
                                  //     builder: (context, state) {
                                  //       return HighScorePageNavigationButton();
                                  //     }),
                                  flutter_bloc.BlocBuilder<CoinBloc, CoinState>(
                                      builder: (context, state) {
                                    return CreditPanel(
                                        '\$: ' + state.amount.toString(),
                                        30,
                                        creditPanelWidth);
                                  })
                                ],
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                        Align(
                          alignment: darkPatternsBloc.state
                                  is DarkPatternsActivatedState
                              ? Alignment.bottomCenter
                              : Alignment.topCenter,
                          child: AspectRatio(
                            aspectRatio: 0.65,
                            child: SizedBox(
                                width: levelsWidth,
                                height: levelsWidth,
                                child: StreamBuilder<int>(
                                    stream: gameBloc.maxLevelNumber,
                                    builder: (context, snapshot) {
                                      return GridView.builder(
                                        itemCount: snapshot.data,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 1.11,
                                        ),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return flutter_bloc.BlocBuilder<
                                              LevelBloc, LevelState>(
                                            builder: (context, state) {
                                              return GameLevelButton(
                                                  width: 80.0,
                                                  height: 60.0,
                                                  borderRadius: 50.0,
                                                  levelNumber: index + 1);
                                            },
                                          );
                                        },
                                      );
                                    })),
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }
}
