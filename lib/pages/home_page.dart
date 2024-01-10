// ignore_for_file: avoid_print
import 'package:audioplayers/audioplayers.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_state.dart';
import 'package:bachelor_flutter_crush/game_widgets/game_level_button.dart';
import 'package:bachelor_flutter_crush/helpers/url_helper.dart';
import 'package:bachelor_flutter_crush/pages/shop_page.dart';
import 'package:bachelor_flutter_crush/persistence/daily_rewards_service.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:bachelor_flutter_crush/services/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

import '../bloc/bloc_provider.dart';
import '../bloc/game_bloc.dart';
import '../bloc/user_state_bloc/coins_bloc/coin_bloc.dart';
import '../bloc/user_state_bloc/coins_bloc/coin_event.dart';
import '../bloc/user_state_bloc/coins_bloc/coin_state.dart';
import '../bloc/user_state_bloc/level_bloc/level_bloc.dart';
import '../bloc/user_state_bloc/level_bloc/level_state.dart';
import '../bloc/user_state_bloc/xp_bloc/xp_event.dart';
import '../controllers/fortune_wheel/fortune_wheel.dart';
import '../gamification_widgets/credit_panel.dart';
import '../helpers/app_colors.dart';
import 'feedback_page.dart';
import 'finished_survey_page.dart';
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
  bool dailyRewardCollected = true;

  int todaysAmount = 0;
  String todaysType = '';

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        FirebaseStore.addStartApp(DateTime.now());
        break;
      case AppLifecycleState.inactive:
        FirebaseStore.addCloseApp(DateTime.now());
        break;
      case AppLifecycleState.detached:
        FirebaseStore.addCloseApp(DateTime.now());
        break;
      case AppLifecycleState.paused:
        FirebaseStore.addCloseApp(DateTime.now());
        break;
      case AppLifecycleState.hidden:
        FirebaseStore.addCloseApp(DateTime.now());
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
    checkForFirstTimeStart();
    checkNotification();
    loadMusic();
    playMusic();
  }

  @override
  void didChangeDependencies() {
    print("didChangeDependencies");
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    audioPlayer.stop();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    loadDailyReward();
    DarkPatternsState darkPatternsState =
        flutter_bloc.BlocProvider.of<DarkPatternsBloc>(context).state;
    GameBloc gameBloc = BlocProvider.of<GameBloc>(context);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Size screenSize = mediaQueryData.size;
    double webWidth = 500;
    double webHeight = 1000;
    double creditPanelWidth = kIsWeb ? webWidth / 4 : screenSize.width / 4;
    return Scaffold(
      appBar: AppBar(
        title: const Text('JellyFun'),
        actions: [
          flutter_bloc.BlocBuilder<DarkPatternsBloc, DarkPatternsState>(
            builder: (context, state) {
              if (state is DarkPatternsActivatedState || state is DarkPatternsCompetitionState) {
                return Tooltip(
                    message: 'Highscore',
                    child: IconButton(
                      icon: const Icon(Icons.scoreboard),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const HighScorePage()));
                      },
                    ));
              } else {
                return Container();
              }
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
      endDrawer: buildBurgerMenu(context, darkPatternsState),
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
                          if (state is DarkPatternsActivatedState ||
                              state is DarkPatternsCompetitionState) {
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
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                flutter_bloc.BlocBuilder<CoinBloc, CoinState>(
                                    builder: (context, state) {
                                  return CreditPanel('\$: ${state.amount}', 30, creditPanelWidth);
                                })
                              ],
                            );
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
                                    if (darkPatternsState is DarkPatternsActivatedState ||
                                        darkPatternsState is DarkPatternsCollectionState) {
                                      return const Divider(
                                        color: Colors.black,
                                        thickness: 5.0,
                                        height: 20.0,
                                      );
                                    } else {
                                      return const Divider(
                                        color: Colors.transparent,
                                        thickness: 0.0,
                                        height: 20.0,
                                      );
                                    }
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
                                                color: darkPatternsState
                                                            is! DarkPatternsActivatedState &&
                                                        darkPatternsState
                                                            is! DarkPatternsCollectionState
                                                    ? AppColors.getColorLevel(1)
                                                    : AppColors.getColorLevel(levelNumber + 1),
                                                buntJelly: buntJelly,
                                                stripeJelly: stripeJelly,
                                                audioPlayer: audioPlayer,
                                              );
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

  bool isMusicOn = true;

  Drawer buildBurgerMenu(BuildContext context, DarkPatternsState darkPatternsState) {
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
            leading: const Icon(Icons.feedback_outlined),
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
                leading: const Icon(Icons.info),
                title: const Text('Info Seite'),
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const DeviceToken()));
                },
                tileColor: Colors.grey[200],
                // Background color to make it feel like a button
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Rounded corners
              )),
          if (darkPatternsState is DarkPatternsActivatedState ||
              darkPatternsState is DarkPatternsFoMoState)
            GestureDetector(
                onTap: () {
                  if (dailyRewardCollected) {
                    _showDailyRewardsCollectedDialog(dailyRewardCollected);
                  }
                },
                child: ListTile(
                  enabled: !dailyRewardCollected,
                  leading: const Icon(Icons.card_giftcard),
                  title: const Text('Tägliche Belohnung'),
                  onTap: () {
                    setState(() {
                      dailyRewardCollected = true;
                      setDailyRewards();
                      FirebaseStore.collectedDailyRewards(DateTime.now());
                    });
                    _showDailyRewardsCollectedDialog(!dailyRewardCollected);
                  },
                  tileColor: Colors.grey[200],
                  // Background color to make it feel like a button
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)), // Rounded corners
                )),
          Visibility(
              visible: true,
              child: ListTile(
                leading: const Icon(Icons.token),
                title: const Text('Imprint'),
                onTap: () {
                  UrlHelper.launchURL('https://www.sba-research.org/imprint/');
                },
                tileColor: Colors.grey[200],
                // Background color to make it feel like a button
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Rounded corners
              )),
          Visibility(
              visible: false,
              child: ListTile(
                leading: const Icon(Icons.token),
                title: const Text('Fortune Wheel'),
                onTap: () {
                  List<int> itemList = [5, (5 * 0.5).ceil(), (5 * 0.75).ceil(), 5 * 2, 5 * 3, 1];
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => FortuneWheel(items: itemList),
                  ));
                },
                tileColor: Colors.grey[200],
                // Background color to make it feel like a button
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Rounded corners
              )),
          Visibility(
              visible: true,
              child: SwitchListTile(
                title: const Text('Musik'),
                secondary: isMusicOn ? const Icon(Icons.music_note) : const Icon(Icons.music_off),
                value: isMusicOn,
                onChanged: (bool value) {
                  setState(() {
                    isMusicOn = value;
                    setMusic();
                  });
                },
              )),
          Visibility(
              visible: true,
              child: ListTile(
                leading: const Icon(Icons.shopping_basket),
                title: const Text('Shop'),
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const ShopPage()));
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
  late int buntJelly;
  late int stripeJelly;

  void loadDailyReward() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var dailyReward = sp.getString("dailyRewards");
    var firstTimeStart = sp.getString("firstStartTime");

    if (dailyReward == null) {
      dailyRewardCollected = false;
    }
    if (dailyReward != null) {
      setState(() {
        difference = DateTime.now().difference(DateTime.parse(dailyReward)).inHours;
      });
      if (difference >= 24) {
        dailyRewardCollected = false;
      }
    }
    setState(() {
      buntJelly = sp.getInt("buntJelly") ?? 0;
      stripeJelly = sp.getInt("stripeJelly") ?? 0;
    });
    if (firstTimeStart == null) {
      var todaysReward = DailyRewardsService.getTodaysReward(1);
      todaysAmount = todaysReward['amount'];
      todaysType = todaysReward['type'];
    } else {
      var daysSinceStart = DateTime.now().difference(DateTime.parse(firstTimeStart)).inDays;
      var todaysReward = DailyRewardsService.getTodaysReward(daysSinceStart + 1);
      todaysAmount = todaysReward['amount'];
      todaysType = todaysReward['type'];
    }
  }

  void setDailyRewards() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("dailyRewards", DateTime.now().toString());
    if (todaysType.contains('bunt')) {
      sp.setInt("buntJelly", buntJelly += todaysAmount);
    } else if (todaysType.contains('gestreift')) {
      sp.setInt("stripeJelly", stripeJelly += todaysAmount);
    } else if (todaysType.contains("XP")) {
      flutter_bloc.BlocProvider.of<XpBloc>(context).add(AddXpEvent(todaysAmount));
    } else if (todaysType.contains("\$")) {
      flutter_bloc.BlocProvider.of<CoinBloc>(context).add(AddCoinsEvent(todaysAmount));
    }
  }

  void _showDailyRewardsCollectedDialog(bool dailyRewardCollected) {
    if (dailyRewardCollected) {
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
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Deine tägliche Belohnung'),
            content: todaysType.contains('Sonderjelly')
                ? Wrap(children: [
                    Text('Heute hast du $todaysAmount $todaysType erhalten. Komm morgen wieder!'),
                    Center(
                      child: Image.asset(
                        todaysType.contains('bunt')
                            ? 'assets/images/bombs/jelly_bunt.png'
                            : 'assets/images/bombs/jelly_gelb.png',
                        height: 30,
                      ),
                    ),
                  ])
                : Text('Heute hast du $todaysAmount $todaysType erhalten. Komm morgen wieder!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    difference = 0;
                  });
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void checkForFirstTimeStart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!kDebugMode) {
      if (prefs.getBool("isUnder18") == true) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Under18Page()));
      }
      var endSurvey = prefs.getString("endSurvey");
      if (endSurvey != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const FinishedSurveyPage()));
      } else if (endSurvey == null) {
        if (DateTime.now().isAfter(DateTime(2023, 12, 23))) {
          Navigator.of(context).pushNamed(
            "/endSurvey",
          );
        }
      }
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
    if (prefs.getBool("firstStart") == null || prefs.getBool("firstStart") == true) {
      if (!kDebugMode) {
        Navigator.of(context).pushNamed(
          "/startSurvey",
        );
      }
    }
  }

  void checkNotification() {
    Uri currentUrl = Uri.parse(html.window.location.href);
    if (currentUrl.queryParameters['source'] == 'notification') {
      print("Tapped Notification");
      FirebaseStore.addNotificationTap(DateTime.now());
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void setMusic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("music", isMusicOn);
    playMusic();
  }

  AudioPlayer audioPlayer = AudioPlayer();

  void loadMusic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isMusicOn = prefs.getBool("music") ?? true;
  }

  void playMusic() {
    print("playMusic $isMusicOn");
    // if (isMusicOn) {
    //   audioPlayer.setReleaseMode(ReleaseMode.loop);
    //   audioPlayer.setVolume(0.5);
    //   Source source = AssetSource('audio/Background_Music.mp3');
    //   audioPlayer.setSource(source);
    //   try {
    //     audioPlayer.resume();
    //   } catch (e) {
    //     print(e);
    //   }
    // } else {
    //   audioPlayer.stop();
    // }
  }
}
