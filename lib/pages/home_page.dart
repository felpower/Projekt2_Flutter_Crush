import 'dart:async';

import 'package:bachelor_flutter_crush/app_bar_widgets/day_streak_icon.dart';
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
import 'package:bachelor_flutter_crush/services/ServiceWorkerNotification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;

import '../bloc/bloc_provider.dart';
import '../bloc/game_bloc.dart';
import '../bloc/user_state_bloc/coins_bloc/coin_bloc.dart';
import '../bloc/user_state_bloc/coins_bloc/coin_state.dart';
import '../bloc/user_state_bloc/day_streak_bloc/day_streak_state.dart';
import '../gamification_widgets/credit_panel.dart';
import '../services/firebase_messaging_web.dart';
import 'feedback_page.dart';
import 'high_score_page.dart';
import 'information_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late StreamSubscription _daystreakMilestoneSubscription;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ReportingBloc reportingBloc = flutter_bloc.BlocProvider.of<ReportingBloc>(context);
    switch (state) {
      case AppLifecycleState.resumed:
        reportingBloc.add(ReportStartAppEvent(DateTime.now()));
        break;
      case AppLifecycleState.inactive:
        ServiceWorkerNotification().scheduleNotification();
        reportingBloc.add(ReportCloseAppEvent(DateTime.now()));
        break;
      case AppLifecycleState.detached:
        ServiceWorkerNotification().scheduleNotification();
        reportingBloc.add(ReportCloseAppEvent(DateTime.now()));
        break;
      case AppLifecycleState.paused:
        ServiceWorkerNotification().scheduleNotification();
        break;
      case AppLifecycleState.hidden:
        ServiceWorkerNotification().scheduleNotification();
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
    ServiceWorkerNotification().requestNotificationPermission();

    // FirebaseMessaging.onMessage.listen(showFlutterNotification);
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    final android = message.notification?.android;
    print('Notification TITLE: ${notification?.title}');
    if (notification != null || android != null) {
      FirebaseMessagingWeb().showNotification(notification);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return Material(
                child: Column(
              children: [
                Text(notification?.title ?? "No Title"),
                Text(notification?.body ?? "No Body"),
              ],
            ));
          });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DarkPatternsBloc darkPatternsBloc = flutter_bloc.BlocProvider.of<DarkPatternsBloc>(context);
    _daystreakMilestoneSubscription =
        flutter_bloc.BlocProvider.of<DayStreakBloc>(context).stream.listen((state) {
      if (state is DayStreakMilestoneState &&
          darkPatternsBloc.state is DarkPatternsActivatedState) {
        OverlayEntry? dayStreakMileStoneSplash;
        dayStreakMileStoneSplash = OverlayEntry(
          builder: (context) {
            return DayStreakMilestoneReachedSplash(state.dayStreak, state.addedCoins, () {
              dayStreakMileStoneSplash?.remove();
            });
          },
        );
        Overlay.of(context).insert(dayStreakMileStoneSplash);
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
    GameBloc gameBloc = BlocProvider.of<GameBloc>(context);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Size screenSize = mediaQueryData.size;
    double webWidth = 500;
    double webHeight = 1000;
    double creditPanelWidth = kIsWeb ? webWidth / 4 : screenSize.width / 4;

    return Scaffold(
      appBar: AppBar(
        leading: const DayStreakIcon(1),
        title: const Text('Flutter Crush'),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
        ],
      ),
      endDrawer: buildBurgerMenu(context),
      body: PopScope(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background/background2.jpg'),
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
                    flutter_bloc.BlocBuilder<DarkPatternsBloc, DarkPatternsState>(
                      builder: (context, state) {
                        if (state is DarkPatternsActivatedState) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              flutter_bloc.BlocBuilder<XpBloc, XpState>(builder: (context, state) {
                                return CreditPanel('XP: ${state.amount}', 30, creditPanelWidth);
                              }),
                              flutter_bloc.BlocBuilder<CoinBloc, CoinState>(
                                  builder: (context, state) {
                                return CreditPanel('\$: ${state.amount}', 30, creditPanelWidth);
                              })
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    Expanded(
                      // Added Expanded to ensure GridView takes up all available space
                      child: StreamBuilder<int>(
                          stream: gameBloc.maxLevelNumber,
                          builder: (context, snapshot) {
                            return GridView.builder(
                              itemCount: snapshot.data,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.11,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return flutter_bloc.BlocBuilder<LevelBloc, LevelState>(
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
                          }),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Drawer buildBurgerMenu(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Menu'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outlined),
            title: const Text('Info Page'),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const InformationPage()));
            },
            tileColor: Colors.grey[200],
            // Background color to make it feel like a button
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file_outlined),
            title: const Text('Start Page'),
            onTap: () {
              Navigator.of(context).pushNamed(
                "/start",
              );
            },
            tileColor: Colors.grey[200],
            // Background color to make it feel like a button
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
          ),
          ListTile(
            leading: const Icon(Icons.scoreboard),
            title: const Text('HighScore'),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const HighScorePage()));
            },
            tileColor: Colors.grey[200],
            // Background color to make it feel like a button
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
          ),
          ListTile(
            leading: const Icon(Icons.notification_add),
            title: const Text('Send Notification'),
            onTap: () {
              ServiceWorkerNotification().sendNotification(
                  "Test Notification", "This is the body of the test Notification", 10);
            },
            tileColor: Colors.grey[200],
            // Background color to make it feel like a button
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
          ),
          ListTile(
            leading: const Icon(Icons.error),
            title: const Text('Exception Test'),
            onTap: () {
              throw Exception('This is a forced exception for testing purposes.');
            },
            tileColor: Colors.grey[200],
            // Background color to make it feel like a button
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const FeedbackPage()));
            },
            tileColor: Colors.grey[200],
            // Background color to make it feel like a button
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
          ),
        ],
      ),
    );
  }
}
