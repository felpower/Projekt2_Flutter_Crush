// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_state.dart';
import 'package:bachelor_flutter_crush/game_widgets/game_level_button.dart';
import 'package:bachelor_flutter_crush/helpers/url_helper.dart';
import 'package:bachelor_flutter_crush/pages/contact_page.dart';
import 'package:bachelor_flutter_crush/pages/shop_page.dart';
import 'package:bachelor_flutter_crush/pages/welcome_page.dart';
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
import '../controllers/advertisement_video_player.dart';
import '../controllers/fortune_wheel/fortune_wheel.dart';
import '../controllers/unity/unity_screen.dart';
import '../gamification_widgets/credit_panel.dart';
import '../helpers/app_colors.dart';
import '../helpers/global_variables.dart';
import 'dark_patterns_page.dart';
import 'feedback_page.dart';
// import 'finished_survey_page.dart';
import 'high_score_page.dart';
import 'info_page.dart';
// import 'under_18_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool dailyRewardCollected = true;
  late ValueNotifier<int> _darkPatternsCountNotifier;
  late AnimationController _controller;
  late Animation<double> _animation;
  int todaysAmount = 0;
  String todaysType = '';
  bool darkPatternsInfoActive = false;
  bool _isHomePageActive = false;

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

  Future<int>? _daysPlayedFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkForFirstTimeStart();
    _daysPlayedFuture = _getDaysPlayed();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _darkPatternsCountNotifier = ValueNotifier<int>(0);
    updateDarkPatternsCount();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('HomePage is active');
      setState(() {
        _isHomePageActive = true;
      });
      _checkLevels();
    });
    isMusicOn.addListener(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('music', isMusicOn.value);
    });
  }

  Future<void> updateDarkPatternsCount() async {
    int count = await _countDarkPatternsFound();
    _darkPatternsCountNotifier.value = count;
  }

  bool checkedForReopenGame = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _darkPatternsCountNotifier.dispose();
    _isHomePageActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DarkPatternsState darkPatternsState =
        flutter_bloc.BlocProvider.of<DarkPatternsBloc>(context).state;
    loadDailyReward(darkPatternsState);
    GameBloc gameBloc = BlocProvider.of<GameBloc>(context);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Size screenSize = mediaQueryData.size;
    double webWidth = 500;
    double webHeight = 1000;
    double creditPanelWidth = kIsWeb ? webWidth / 4 : screenSize.width / 4;

    if (!checkedForReopenGame) {
      checkForReopenGame();
      setState(() {
        checkedForReopenGame = true;
      });
    }
    var host = Uri.parse(html.window.location.href).host;
    _showDarkPatternsInfoNotification();
    return Scaffold(
      appBar: AppBar(
        title: const Text('JellyFun'),
        actions: [
          showPulsatingAppBarIcon(),
          showHighscoreTooltip(),
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  loadDailyReward(darkPatternsState);
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
                  image: AssetImage(
                      'assets/images/background/background_new2.png'),
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
                      flutter_bloc.BlocBuilder<DarkPatternsBloc,
                          DarkPatternsState>(
                        builder: (context, state) {
                          if (state is DarkPatternsActivatedState ||
                              state is DarkPatternsCompetitionState) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                flutter_bloc.BlocBuilder<XpBloc, XpState>(
                                    builder: (context, state) {
                                  return CreditPanel('XP: ${state.amount}', 30,
                                      creditPanelWidth);
                                }),
                                flutter_bloc.BlocBuilder<CoinBloc, CoinState>(
                                    builder: (context, state) {
                                  return CreditPanel('🪙: ${state.amount}', 30,
                                      creditPanelWidth);
                                })
                              ],
                            );
                          } else {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                flutter_bloc.BlocBuilder<CoinBloc, CoinState>(
                                    builder: (context, state) {
                                  return CreditPanel('🪙: ${state.amount}', 30,
                                      creditPanelWidth);
                                })
                              ],
                            );
                          }
                        },
                      ),
                      flutter_bloc.BlocBuilder<DarkPatternsBloc,
                          DarkPatternsState>(builder: (context, state) {
                        return Visibility(
                            visible: host.contains('felpower') ||
                                host.contains('localhost'),
                            child: const Text(
                              'Dies ist eine TestVersion und wird nicht für die Studie verwendet. Um an der richtigen Studie teilzunehmen bitte die Seite jelly-fun.github.io aufrufen.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ));
                      }),
                      flutter_bloc.BlocBuilder<DarkPatternsBloc,
                          DarkPatternsState>(
                        builder: (context, state) {
                          return Visibility(
                            visible: darkPatternsState
                                    is DarkPatternsActivatedState ||
                                darkPatternsState is DarkPatternsFoMoState,
                            child: FutureBuilder<int>(
                              future: _daysPlayedFuture,
                              builder: (BuildContext context,
                                  AsyncSnapshot<int> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return const Text(
                                      'Vergiss nicht deine tägliche Belohnung im Menü '
                                      'oben abzuholen!',
                                      textAlign: TextAlign.center);
                                } else {
                                  int daysPlayed = snapshot.data!;
                                  if (daysPlayed >= 3) {
                                    return Container();
                                  } else {
                                    return const Text(
                                        "Vergiss nicht deine tägliche Belohnung im Menü abzuholen!",
                                        textAlign: TextAlign.center);
                                  }
                                }
                              },
                            ),
                          );
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
                              int itemCount =
                                  (levelCount / 3).ceil() + totalDividers;
                              return ListView.builder(
                                itemCount: itemCount,
                                itemBuilder: (BuildContext context, int index) {
                                  // Check if the current index is a divider row
                                  bool isDividerRow =
                                      (index + 1) % 3 == 0 && index != 0;
                                  if (isDividerRow) {
                                    // Return a divider for the designated rows
                                    if (darkPatternsState
                                            is DarkPatternsActivatedState ||
                                        darkPatternsState
                                            is DarkPatternsCollectionState) {
                                      return const Divider(
                                        color: Colors.black,
                                        thickness: 5.0,
                                        height: 20.0,
                                      );
                                    } else {
                                      return const Divider(
                                        color: Colors.transparent,
                                        thickness: 5.0,
                                        height: 20.0,
                                      );
                                    }
                                  } else {
                                    // Calculate how many dividers come before the current index
                                    int dividersBefore =
                                        ((index + 1) / 3).floor();
                                    // Calculate the first level number for this row, adjusting for dividers
                                    int levelIndex = index - dividersBefore;
                                    int firstLevelNumber = levelIndex * 3;
                                    // Generate a row with up to 3 level buttons
                                    return Row(
                                      children: List<Widget>.generate(3,
                                          (buttonIndex) {
                                        // Calculate the level number for this button
                                        int levelNumber =
                                            firstLevelNumber + buttonIndex;
                                        if (levelNumber < levelCount) {
                                          // If within range, return a GameLevelButton
                                          return Expanded(
                                            child: flutter_bloc.BlocBuilder<
                                                    LevelBloc, LevelState>(
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
                                                    : AppColors.getColorLevel(
                                                        levelNumber + 1),
                                                buntJelly: buntJelly,
                                                stripeJelly: stripeJelly,
                                              );
                                            }),
                                          );
                                        } else {
                                          // If the levelNumber exceeds levelCount, return an empty widget
                                          return const Expanded(
                                              child: SizedBox.shrink());
                                        }
                                      }),
                                    );
                                  }
                                },
                              );
                            } else {
                              // Handle the case when snapshot doesn't have data
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  flutter_bloc.BlocBuilder<DarkPatternsBloc, DarkPatternsState>
      showHighscoreTooltip() {
    return flutter_bloc.BlocBuilder<DarkPatternsBloc, DarkPatternsState>(
      builder: (context, state) {
        if (state is DarkPatternsActivatedState ||
            state is DarkPatternsCompetitionState) {
          return Tooltip(
              message: 'Highscore',
              child: IconButton(
                icon: const Icon(Icons.emoji_events, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HighScorePage()));
                },
              ));
        } else {
          return Container();
        }
      },
    );
  }

  Stack showPulsatingAppBarIcon() {
    return Stack(
      children: [
        Tooltip(
          message: 'Shop',
          child: IconButton(
            icon: const Icon(Icons.shopping_basket_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopPage()),
              );
            },
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Opacity(
                  opacity: _animation.value,
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.red.withOpacity(0.9),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Drawer buildBurgerMenu(
      BuildContext context, DarkPatternsState darkPatternsState) {
    updateDarkPatternsCount();
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Menü'),
          ),
          Visibility(
              visible: true,
              child: ListTile(
                leading: const Icon(Icons.ad_units),
                title: const Text('Watch Adds for 🪙',
                    style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AdvertisementVideoPlayer(isForcedAd: false),
                    ),
                  );
                },
                tileColor: Colors.grey[200],
                // Background color to make it feel like a button
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Rounded corners
              )),
          Visibility(
              visible: true,
              child: ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Instruktionen',
                    style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DeviceToken()));
                },
                tileColor: Colors.grey[200],
                // Background color to make it feel like a button
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Rounded corners
              )),
          Visibility(
              visible: true,
              child: ListTile(
                leading: const Icon(Icons.shopping_basket),
                title: const Text('Shop', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ShopPage()));
                },
                tileColor: Colors.grey[200],
                // Background color to make it feel like a button
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Rounded corners
              )),
          Visibility(
              visible: darkPatternsState is! DarkPatternsDeactivatedState &&
                  (Uri.parse(html.window.location.href)
                          .host
                          .contains('felpower') ||
                      Uri.parse(html.window.location.href)
                          .host
                          .contains('localhost')),
              child: ListTile(
                leading: const Icon(Icons.pattern),
                title: const Text('Reset Dark Patterns',
                    style: TextStyle(color: Colors.grey)),
                onTap: () {
                  resetDarkPatterns();
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
                  title: const Text('Tägliche Belohnung',
                      style: TextStyle(color: Colors.grey)),
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
                      borderRadius:
                          BorderRadius.circular(12)), // Rounded corners
                )),
          Visibility(
              visible: true,
              child: ValueListenableBuilder<bool>(
                valueListenable: isMusicOn,
                // This is the ValueNotifier from unity_screen.dart
                builder: (context, value, child) {
                  return SwitchListTile(
                    tileColor: Colors.grey[200],
                    title: const Text('Musik',
                        style: TextStyle(color: Colors.grey)),
                    secondary: value
                        ? const Icon(Icons.music_note)
                        : const Icon(Icons.music_off),
                    value: value,
                    onChanged: (bool newValue) {
                      isMusicOn.value = newValue;
                    },
                  );
                },
              )),
          Visibility(
            visible: Uri.parse(html.window.location.href)
                    .host
                    .contains('felpower') ||
                Uri.parse(html.window.location.href)
                    .host
                    .contains('localhost') ||
                Uri.parse(html.window.location.href).host.contains('flutter'),
            child: ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback senden',
                  style: TextStyle(color: Colors.grey)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedbackPage()));
              },
              tileColor: Colors.grey[200],
              // Background color to make it feel like a button
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)), // Rounded corners
            ),
          ),
          Visibility(
              visible: true,
              child: ListTile(
                leading: const Icon(Icons.token),
                title:
                    const Text('Imprint', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  UrlHelper.launchURL('https://www.sba-research.org/imprint/');
                },
                tileColor: Colors.grey[200],
                // Background color to make it feel like a button
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Rounded corners
              )),
          Visibility(
              visible: true,
              child: ListTile(
                leading: const Icon(Icons.info),
                title:
                    const Text('Kontakt', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ContactPage()));
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
                title: const Text('Fortune Wheel',
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  List<int> itemList = [
                    5,
                    (5 * 0.5).ceil(),
                    (5 * 0.75).ceil(),
                    5 * 2,
                    5 * 3,
                    1
                  ];
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
              visible: false,
              child: ListTile(
                leading: const Icon(Icons.question_mark),
                title: const Text('End Survey',
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    "/endSurvey",
                  );
                },
                tileColor: Colors.grey[200],
                // Background color to make it feel like a button
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Rounded corners
              )),
          ValueListenableBuilder<int>(
            valueListenable: _darkPatternsCountNotifier,
            builder: (context, count, child) {
              return ListTile(
                leading: const Icon(Icons.info),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DarkPatternsPage()));
                },
                title: Text('Dark Patterns gefunden $count/7',
                    style: const TextStyle(color: Colors.black)),
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Rounded corners
              );
            },
          ),
        ],
      ),
    );
  }

  Future<int> _countDarkPatternsFound() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int count = 0;
    if (prefs.getBool('darkPatternsInfoNotification') ?? false) count++;
    if (prefs.getBool('darkPatternsInfoVAR') ?? false) count++;
    if (prefs.getBool('darkPatternsInfoScore') ?? false) count++;
    if (prefs.getBool('darkPatternsInfoShop') ?? false) count++;
    if (prefs.getBool('darkPatternsInfoFoMo') ?? false) count++;
    if (prefs.getBool('darkPatternsInfoAdds') ?? false) count++;
    if (prefs.getBool('darkPatternsInfoCompleted') ?? false) count++;
    return count;
  }

  late int difference;
  late int buntJelly;
  late int stripeJelly;

  void loadDailyReward(DarkPatternsState darkPatternsState) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var dailyReward = sp.getString("dailyRewards");
    var firstTimeStart = sp.getString("firstStartTime");

    if (dailyReward == null) {
      dailyRewardCollected = false;
    }
    if (dailyReward != null) {
      setState(() {
        difference =
            DateTime.now().difference(DateTime.parse(dailyReward)).inHours;
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
      var todaysReward =
          DailyRewardsService.getTodaysReward(1, darkPatternsState);
      todaysAmount = todaysReward['amount'];
      todaysType = todaysReward['type'];
    } else {
      var daysSinceStart =
          DateTime.now().difference(DateTime.parse(firstTimeStart)).inDays;
      var todaysReward = DailyRewardsService.getTodaysReward(
          daysSinceStart + 1, darkPatternsState);
      todaysAmount = todaysReward['amount'];
      todaysType = todaysReward['type'];
    }
  }

  Future<int> _getDaysPlayed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime? startDate =
        DateTime.tryParse(prefs.getString("firstTimeStart") ?? "");
    startDate ??= DateTime.now();
    int daysPlayed = DateTime.now().difference(startDate).inDays;
    return daysPlayed;
  }

  void setDailyRewards() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("dailyRewards", DateTime.now().toString());
    if (todaysType.contains('bunt')) {
      sp.setInt("buntJelly", buntJelly += todaysAmount);
    } else if (todaysType.contains('gestreift')) {
      sp.setInt("stripeJelly", stripeJelly += todaysAmount);
    } else if (todaysType.contains("XP")) {
      flutter_bloc.BlocProvider.of<XpBloc>(context)
          .add(AddXpEvent(todaysAmount));
    } else if (todaysType.contains("🪙")) {
      flutter_bloc.BlocProvider.of<CoinBloc>(context)
          .add(AddCoinsEvent(todaysAmount));
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
            content: Text(
                'Tägliche Belohnung können wieder in $actualDifference Stunden abgeholt '
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
                    Text(
                        'Heute hast du $todaysAmount $todaysType erhalten. Komm morgen wieder!'),
                    Center(
                      child: Image.asset(
                        todaysType.contains('bunt')
                            ? 'assets/images/bombs/jelly_bunt.png'
                            : 'assets/images/bombs/jelly_gelb.png',
                        height: 30,
                      ),
                    ),
                  ])
                : Text(
                    'Heute hast du $todaysAmount $todaysType erhalten. Komm morgen wieder!'),
            actions: [
              TextButton(
                onPressed: () {
                  _showDarkPatternsInfoFoMo();
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

  void _showDarkPatternsInfoNotification() async {
    if (darkPatternsInfoActive) {
      return;
    }
    darkPatternsInfoActive = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isExpanded = false;
    var dpInfoShown = prefs.getBool('darkPatternsInfoNotification');
    var fromNotification = prefs.getBool('fromNotification');

    if ((fromNotification != null && fromNotification == true) &&
        (dpInfoShown == null || dpInfoShown == false)) {
      print(
          "fromNotification: $fromNotification and dpInfoShown: $dpInfoShown");
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Das war gerade ein Dark Pattern!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Hast du schon einmal gespielt, nur weil dir eine Push-Benachrichtigung vorgeschlagen hat, jetzt wieder einzusteigen?'),
                    if (isExpanded)
                      const Text(
                        'Oft werden solche Nachrichten genutzt, um Druck aufzubauen – vielleicht wurde dir ein zeitlich begrenzter Bonus versprochen oder Extra-Punkte, wenn du sofort spielst. Diese Benachrichtigungen sollen dich daran erinnern, das Spiel zu öffnen, auch wenn du gar nicht daran gedacht hast. Entwickler setzen darauf, dass du durch den Hinweis neugierig wirst und nicht widerstehen kannst, es gleich auszuprobieren.',
                      ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isExpanded ? "" : 'Mehr erfahren'),
                          isExpanded
                              ? const Icon(Icons.expand_less)
                              : const Icon(Icons.expand_more),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      prefs.setBool('darkPatternsInfoNotification', true);
                      prefs.setBool('fromNotification', false);
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

  void _showDarkPatternsInfoFoMo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isExpanded = false;
    var dpInfoShown = prefs.getBool('darkPatternsInfoFoMo');

    if (dpInfoShown == null || dpInfoShown == false) {
      return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Das war gerade ein Dark Pattern!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Hast du bemerkt, dass du täglich eine kleine Überraschung bekommst, wenn du das Spiel öffnest?'),
                    if (isExpanded)
                      const Text(
                        'Diese täglichen Belohnungen sind so gestaltet, dass du motiviert wirst, immer wieder zurückzukehren, um nichts zu verpassen. Je länger du spielst, desto größer wird oft die Belohnung. So entsteht der Druck, das Spiel wirklich jeden Tag zu öffnen, um die maximale Belohnung zu sichern. Genau das ist der Trick dahinter: Dich regelmäßig ins Spiel zu locken, damit du dranbleibst.',
                      ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isExpanded ? "" : 'Mehr erfahren'),
                          isExpanded
                              ? const Icon(Icons.expand_less)
                              : const Icon(Icons.expand_more),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      prefs.setBool('darkPatternsInfoFoMo', true);
                      Navigator.of(context).pop();
                      setState(() {
                        updateDarkPatternsCount();
                      });
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

  void checkForFirstTimeStart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!kDebugMode) {
      // if (prefs.getBool("isUnder18") == true) {
      //   Navigator.push(context, MaterialPageRoute(builder: (context) => const Under18Page()));
      // }
      if (prefs.getBool("firstStart") == null ||
          prefs.getBool("firstStart") == true) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const WelcomePage()));
      }
      // var endSurvey = prefs.getString("endSurvey");
      // if (endSurvey != null) {
      //   Navigator.push(
      //       context, MaterialPageRoute(builder: (context) => const FinishedSurveyPage()));
      // } else if (endSurvey == null) {
      //   var firstTimeStart = prefs.getString("firstStartTime");
      //   if (firstTimeStart != null &&
      //       DateTime.now().difference(DateTime.parse(firstTimeStart)).inDays > 30) {
      //     Navigator.of(context).pushNamed(
      //       "/endSurvey",
      //     );
      //   }
      // }
    }
    FutureBuilder<String>(
        future: FirebaseMessagingWeb.getToken(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            print(snapshot.data!);
            return Text(snapshot.data!);
          }
          return const CircularProgressIndicator();
        });
  }

  Future<void> checkForReopenGame() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var levelStarted = prefs.getString("levelStarted") ?? "0";
      if (levelStarted == "0") {
        return;
      }
      if (levelStarted != "-1") {
        var level = levelStarted;
        Map<String, dynamic>? jsonData = jsonDecode(levelStarted);
        levelStarted = "0";
        prefs.setString("levelStarted", "0");
        if (jsonData != null) {
          FirebaseStore.sendLog("RestartGame", "Level $level");

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UnityScreen(
                  jsonData: jsonData,
                ),
              ));
        } else {
          throw Exception("Level $levelStarted not found, jsonData is null");
        }
      }
    } catch (e) {
      FirebaseStore.sendError("RestartGame", stacktrace: e.toString());
    }
  }

  void resetDarkPatterns() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkPatternsInfoNotification', false);
    prefs.setBool('darkPatternsInfoVAR', false);
    prefs.setBool('darkPatternsInfoScore', false);
    prefs.setBool('darkPatternsInfoShop', false);
    prefs.setBool('darkPatternsInfoFoMo', false);
    prefs.setBool('darkPatternsInfoAdds', false);
    prefs.setBool('darkPatternsInfoCompleted', false);

    setState(() {
      updateDarkPatternsCount();
    });

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('DarkPatterns zurückgesetzt'),
          content: const Text('Die DarkPatterns wurden zurückgesetzt'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<String>? previousLevels;

  Future<void> _checkLevels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? levels = prefs.getStringList('level');
    print("Levels: $previousLevels");
    if (_isHomePageActive &&
        levels != null &&
        levels.contains("6") &&
        !levels.contains("7") &&
        (previousLevels == null || !previousLevels!.contains("6"))) {
      //Ensure to make it show only when the user is on the homepage
      _showDarkPatternsInfoCompleted();
    }

    // Update previous levels
    previousLevels = levels;
  }

  void _showDarkPatternsInfoCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isExpanded = false;
    var dpInfoShown = prefs.getBool('darkPatternsInfoCompleted');
    print("dpInfoShown: $dpInfoShown");
    if (dpInfoShown == null || dpInfoShown == false) {
      prefs.setBool('darkPatternsInfoCompleted', true);
      return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Das war gerade ein Dark Pattern!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Das Gefühl, deine Sammlung im Spiel endlich vervollständigt zu haben, ist ein typisches Dark Pattern, das in vielen Smartphone-Spielen verwendet wird. '),
                    if (isExpanded)
                      const Text(
                        'Die Sammlungen sind so gestaltet, dass du das Bedürfnis verspürst, jedes einzelne Item zu erwerben, um die vollständige Belohnung zu erhalten. Oft fehlt dir am Ende nur noch ein kleines Teil, und das Spiel bietet dir gezielt die Möglichkeit, dieses fehlende Item entweder durch stundenlanges Spielen oder gegen echtes Geld zu bekommen. Hast du bemerkt, wie zufriedenstellend es ist, eine Sammlung abzuschließen? Oder dass du immer wieder spielst oder sogar Geld ausgibst, nur um das letzte Teil zu erhalten? Das ist genau so beabsichtigt: Spieleentwickler wollen, dass du dich motiviert fühlst, diese letzte Lücke zu füllen, indem du mehr Zeit im Spiel verbringst oder Geld investierst, um das Gefühl der Vollständigkeit zu erreichen.',
                      ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isExpanded ? "" : 'Mehr erfahren'),
                          isExpanded
                              ? const Icon(Icons.expand_less)
                              : const Icon(Icons.expand_more),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      prefs.setBool('darkPatternsInfoCompleted', true);
                      Navigator.of(context).pop();
                      setState(() {
                        updateDarkPatternsCount();
                      });
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
}
