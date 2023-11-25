// ignore_for_file: avoid_print
import 'dart:async';

import 'package:bachelor_flutter_crush/app_bar_widgets/day_streak_icon.dart';
import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_event.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/day_streak_bloc/day_streak_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_state.dart';
import 'package:bachelor_flutter_crush/controllers/fortune_wheel/fortune_wheel.dart';
import 'package:bachelor_flutter_crush/game_widgets/game_level_button.dart';
import 'package:bachelor_flutter_crush/gamification_widgets/daystreak_milestone_reached_splash.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:bachelor_flutter_crush/services/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/bloc_provider.dart';
import '../bloc/game_bloc.dart';
import '../bloc/user_state_bloc/coins_bloc/coin_bloc.dart';
import '../bloc/user_state_bloc/coins_bloc/coin_state.dart';
import '../bloc/user_state_bloc/day_streak_bloc/day_streak_state.dart';
import '../bloc/user_state_bloc/level_bloc/level_bloc.dart';
import '../bloc/user_state_bloc/level_bloc/level_state.dart';
import '../gamification_widgets/credit_panel.dart';
import '../helpers/app_colors.dart';
import 'feedback_page.dart';
import 'high_score_page.dart';
import 'info_page.dart';
import 'under_18_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late StreamSubscription _daystreakMilestoneSubscription;

  bool dailyRewardCollected = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ReportingBloc reportingBloc = flutter_bloc.BlocProvider.of<ReportingBloc>(context);
    switch (state) {
      case AppLifecycleState.resumed:
        reportingBloc.add(ReportStartAppEvent(DateTime.now()));
        break;
      case AppLifecycleState.inactive:
        reportingBloc.add(ReportCloseAppEvent(DateTime.now()));
        break;
      case AppLifecycleState.detached:
        reportingBloc.add(ReportCloseAppEvent(DateTime.now()));
        break;
      case AppLifecycleState.paused:
        reportingBloc.add(ReportCloseAppEvent(DateTime.now()));
        break;
      case AppLifecycleState.hidden:
        reportingBloc.add(ReportCloseAppEvent(DateTime.now()));
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
    checkForNotificationClick();
    loadDailyReward();
    checkForFirstTimeStart();
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
                icon: const Icon(Icons.scoreboard),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const HighScorePage()));
                },
              );
            },
          ),
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  loadDailyReward();
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
                  image: AssetImage('assets/images/background/background_new2.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              heightFactor: 1,
              child: SizedBox(
                width: kIsWeb ? webWidth : null,
                height: kIsWeb ? webHeight : null,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      flutter_bloc.BlocBuilder<DarkPatternsBloc, DarkPatternsState>(
                        builder: (context, state) {
                          if (state is DarkPatternsActivatedState) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                flutter_bloc.BlocBuilder<XpBloc, XpState>(
                                    builder: (context, state) {
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
                            if (snapshot.hasData) {
                              int levelCount = snapshot.data!;
                              // Calculate the total number of dividers we will have
                              int totalDividers = (levelCount / 6).ceil();
                              // Calculate total item count: level rows + divider rows
                              int itemCount = (levelCount / 3).ceil() + totalDividers;
                              return ListView.builder(
                                itemCount: itemCount,
                                itemBuilder: (BuildContext context, int index) {
                                  // Check if the current index is a divider row
                                  bool isDividerRow = (index + 1) % 3 == 0 && index != 0;
                                  if (isDividerRow) {
                                    // Return a divider for the designated rows
                                    return const Divider(
                                      color: Colors.black,
                                      thickness: 5.0,
                                      height: 20.0,
                                    );
                                  } else {
                                    // Calculate how many dividers come before the current index
                                    int dividersBefore = ((index + 1) / 3).floor();
                                    // Calculate the first level number for this row, adjusting for dividers
                                    int levelIndex = index - dividersBefore;
                                    int firstLevelNumber = levelIndex * 3;
                                    // Generate a row with up to 3 level buttons
                                    return Row(
                                      children: List<Widget>.generate(3, (buttonIndex) {
                                        // Calculate the level number for this button
                                        int levelNumber = firstLevelNumber + buttonIndex;
                                        if (levelNumber < levelCount) {
                                          // If within range, return a GameLevelButton
                                          return Expanded(
                                            child: flutter_bloc.BlocBuilder<LevelBloc, LevelState>(
                                                builder: (context, state) {
                                              return GameLevelButton(
                                                  width: 80.0,
                                                  height: 60.0,
                                                  borderRadius: 50.0,
                                                  levelNumber: levelNumber + 1,
                                                  color: AppColors.getColorLevel(levelNumber + 1));
                                            }),
                                          );
                                        } else {
                                          // If the levelNumber exceeds levelCount, return an empty widget
                                          return const Expanded(child: SizedBox.shrink());
                                        }
                                      }),
                                    );
                                  }
                                },
                              );
                            } else {
                              // Handle the case when snapshot doesn't have data
                              return const Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
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
            child: Text('Menü'),
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback senden'),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const FeedbackPage()));
            },
            tileColor: Colors.grey[200],
            // Background color to make it feel like a button
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
          ),
          Visibility(
              visible: true,
              child: ListTile(
                leading: const Icon(Icons.token),
                title: const Text('Info Page'),
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const DeviceToken()));
                },
                tileColor: Colors.grey[200],
                // Background color to make it feel like a button
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Rounded corners
              )),
          GestureDetector(
              onTap: () {
                if (dailyRewardCollected) {
                  _showDailyRewardsCollectedDialog();
                }
              },
              child: ListTile(
                enabled: true,
                // enabled: !dailyRewardCollected,
                leading: const Icon(Icons.card_giftcard),
                title: const Text('Tägliche Belohnung'),
                onTap: () {
                  List<int> itemList = [
                    10,
                    (10 * 0.5).toInt(),
                    (10 * 0.75).toInt(),
                    10 * 2,
                    10 * 3,
                    0
                  ];
                  setState(() {
                    dailyRewardCollected = true;
                    setDailyRewards();
                    FirebaseStore.collectedDailyRewards(DateTime.now());
                  });
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => FortuneWheel(items: itemList)));
                },
                tileColor: Colors.grey[200],
                // Background color to make it feel like a button
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Rounded corners
              )),
        ],
      ),
    );
  }

  late int difference;

  void loadDailyReward() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var dailyReward = sp.getString("dailyRewards");
    if (dailyReward == null) {
      dailyRewardCollected = false;
      setDailyRewards();
    }
    if (dailyReward != null) {
      setState(() {
        difference = DateTime.now().difference(DateTime.parse(dailyReward)).inHours;
      });
      if (difference >= 24) {
        dailyRewardCollected = false;
        setDailyRewards();
      }
    }
  }

  void setDailyRewards() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("dailyRewards", DateTime.now().toString());
  }

  void _showDailyRewardsCollectedDialog() {
    var actualDifference = 24 - difference;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tägliche Belohnung bereits abgeholt'),
          content: Text('Tägliche Belohnung können wieder in $actualDifference Stunden abgeholt '
              'werden'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void checkForFirstTimeStart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getBool("isUnder18");
    if (prefs.getBool("isUnder18") == true) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Under18Page()));
    }
    FutureBuilder<String>(
        future: FirebaseMessagingWeb.getToken(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            print(snapshot.data!);
            return Text(snapshot.data!);
          }
          return const CircularProgressIndicator();
        });
    FirebaseMessagingWeb.requestPermission();
    if (prefs.getBool("firstTimeStart") == null) {
      FirebaseStore.addInitApp(DateTime.now());
      prefs.setBool("firstTimeStart", false);
      Navigator.of(context).pushNamed(
        "/startSurvey",
      );
    }
  }

  void checkForNotificationClick() {
    Uri currentUrl = Uri.base;
    print("currentUrl $currentUrl Query Parameter ${currentUrl.queryParameters['source']}");
    if (currentUrl.queryParameters['source'] == 'notification') {
      print("Tapped Notification");
      FirebaseStore.addNotificationTap(DateTime.now());
    }
  }
}
