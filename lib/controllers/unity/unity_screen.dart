// ignore_for_file: avoid_print

import 'dart:async';

import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/level_bloc/level_event.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/bloc_provider.dart';
import '../../bloc/game_bloc.dart';
import '../../bloc/reporting_bloc/reporting_bloc.dart';
import '../../bloc/reporting_bloc/reporting_event.dart';
import '../../bloc/user_state_bloc/coins_bloc/coin_bloc.dart';
import '../../bloc/user_state_bloc/coins_bloc/coin_event.dart';
import '../../bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import '../../bloc/user_state_bloc/level_bloc/level_bloc.dart';
import '../../game_widgets/game_over_splash.dart';
import '../../game_widgets/game_splash.dart';
import '../fortune_wheel/fortune_wheel.dart';

int coins = 0;

class UnityScreen extends StatefulWidget {
  const UnityScreen({Key? key, required this.levelNumber}) : super(key: key);

  final int levelNumber;

  @override
  State<UnityScreen> createState() => _UnityScreenState();
}

class _UnityScreenState extends State<UnityScreen> {
  late GameBloc gameBloc;
  late LevelBloc levelBloc;
  late DarkPatternsBloc darkPatternsBloc;
  UnityWidgetController? unityWidgetController;
  late OverlayEntry _gameSplash;
  final PublishSubject<bool> _gameIsOverController = PublishSubject<bool>();
  late CoinBloc coinBloc;
  int shufflePrice = 50;
  bool unityReady = false;
  String powerUp = "";

  Stream<bool> get gameIsOver => _gameIsOverController.stream;
  late int lvl;
  bool gameOver = false;
  late bool _gameOverReceived;
  bool fabVisible = true;

  bool isMusicOn = false;

  late StreamSubscription _gameOverSubscription;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _gameOverReceived = false;
    WidgetsBinding.instance.addPostFrameCallback(_showGameStartSplash);
    loadCoins();
    levelBloc = flutter_bloc.BlocProvider.of<LevelBloc>(context);
    darkPatternsBloc = flutter_bloc.BlocProvider.of<DarkPatternsBloc>(context);
  }

  void loadCoins() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = (prefs.getInt('coin') ?? 10);
      powerUp = (prefs.getString("powerUp") ?? "");
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Now that the context is available, retrieve the gameBloc
    gameBloc = BlocProvider.of<GameBloc>(context);

    // Listen to "game over" notification
    _gameOverSubscription = gameIsOver.listen(showGameOver);
  }

  @override
  dispose() {
    _gameOverSubscription.cancel();
    unityWidgetController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    lvl = widget.levelNumber;
    coinBloc = flutter_bloc.BlocProvider.of<CoinBloc>(context);
    return PopScope(
        canPop: false,
        child: Scaffold(
          floatingActionButton: PointerInterceptor(
            child: Visibility(
                visible: !gameOver,
                child: FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    'assets/images/others/close.png',
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => PointerInterceptor(
                                child: AlertDialog(
                              title: const Text('Level abbrechen'),
                              content: const Text('Bist du sicher, dass du das Level abbrechen '
                                  'wollen?'),
                              elevation: 24,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(16))),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () => {Navigator.pop(context, 'Cancel')},
                                    child: const Text('Nein')),
                                TextButton(
                                    onPressed: () => {
                                          flutter_bloc.BlocProvider.of<ReportingBloc>(context)
                                              .add(ReportFinishLevelEvent(lvl, false)),
                                          popUntil()
                                        },
                                    child: const Text('Ja')),
                              ],
                            )));
                  },
                )),
          ),
          body: Stack(
            children: [
              Card(
                  margin: const EdgeInsets.all(0),
                  clipBehavior: Clip.hardEdge,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  child: UnityWidget(
                    onUnityCreated: onUnityCreated,
                    onUnityMessage: onUnityMessage,
                    onUnitySceneLoaded: onUnitySceneLoaded,
                    useAndroidViewSurface: false,
                  )),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: PointerInterceptor(
                      child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      setState(() {
                        isMusicOn = !isMusicOn;
                        prefs.setBool('music', isMusicOn);
                        changeMusic();
                      });
                    },
                    child: isMusicOn ? const Icon(Icons.music_note) : const Icon(Icons.music_off),
                  )),
                ),
              ),
            ],
          ),
        ));
  }

  void popUntil() {
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  int star = 0;

  void shuffleDialog() {
    !gameOver
        ? showDialog(
            context: context,
            builder: (BuildContext context) => PointerInterceptor(
                child: coins > shufflePrice
                    ? AlertDialog(
                        title: const Text('Keine Züge mehr möglich'),
                        content: Text('Willst du $shufflePrice Münzen ausgeben für einen Shuffle? '
                            'Aktuell hast du $coins Münzen'),
                        elevation: 24,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16))),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () => {
                                    unityWidgetController?.postMessage(
                                        'Level', 'ShufflePieces', "ShufflePieces"),
                                    Navigator.pop(context, 'Cancel'),
                                    coinBloc.add(RemoveCoinsEvent(shufflePrice)),
                                    loadCoins()
                                  },
                              child: const Text('Ja')),
                          TextButton(
                              onPressed: () => {
                                    star > 0 ? gameWon(star) : gameLost(),
                                    Navigator.of(context).pop()
                                  },
                              child: const Text('Spiel vorbei')),
                        ],
                      )
                    : AlertDialog(
                        title: const Text('Keine Züge mehr möglich'),
                        content:
                            Text('Du hast nicht genügend Münzen $shufflePrice für einen Shuffle? '
                                'Du hast aktuell '
                                '$coins Münzen. Das Spiel ist vorbei'),
                        elevation: 24,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16))),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () => {star > 0 ? gameWon(star) : gameLost(), popUntil()},
                              child: const Text('OK')),
                        ],
                      )))
        : null;
  }

  void gameWon(message) {
    levelBloc.add(AddLevelEvent(lvl + 1));

    setState(() {
      fabVisible = false;
    });
    var xpCoins = 0;
    if (message is int) {
      xpCoins = lvl * message;
    } else {
      xpCoins = lvl * int.parse(message.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    if (darkPatternsBloc.state is DarkPatternsActivatedState ||
        darkPatternsBloc.state is DarkPatternsRewardsState) {
      gameOver = true;
      showFortuneWheel(xpCoins);
    } else {
      gameBloc.gameOver(xpCoins);
      showGameOver(true);
      gameOver = true;
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pop();
      });
    }
  }

  void showFortuneWheel(int xpCoins) async {
    List<int> itemList = [
      xpCoins,
      (xpCoins * 0.5).ceil(),
      (xpCoins * 0.75).ceil(),
      xpCoins * 2,
      xpCoins * 3,
      1
    ];

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => FortuneWheel(items: itemList),
      ));
    });
  }

  void gameLost() {
    setState(() {
      fabVisible = false;
    });
    gameOver = true;
    gameBloc.gameOver(0);
    _gameIsOverController.sink.add(false);
    showGameOver(false);
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
    });
  }

  void onUnityMessage(message) {
    try {
      if (message.startsWith("checkReady")) {
        unityReady = true;
      }
      if (message.startsWith("Resend Level Info")) {
        changeScene();
        return;
      }
      if (message.startsWith("Score: ")) {
        return;
      } else if (message.startsWith("Shuffle")) {
        shuffleDialog();
        return;
      } else if (message.startsWith("GameOver: Won") && !gameOver) {
        flutter_bloc.BlocProvider.of<ReportingBloc>(context).add(ReportFinishLevelEvent(lvl, true));
        gameWon(message);
      } else if (message.startsWith("GameOver: Lost") && !gameOver) {
        flutter_bloc.BlocProvider.of<ReportingBloc>(context)
            .add(ReportFinishLevelEvent(lvl, false));
        gameLost();
      } else if (message.startsWith("Reached Star:")) {
        star = int.parse(message.replaceAll(RegExp(r'[^0-9]'), ''));
      }
    } catch (e) {
      FirebaseStore.sendError("onUnityMessage", stacktrace: e.toString());
    }
  }

  void onUnitySceneLoaded(SceneLoaded? scene) {
    try {
      if (scene != null) {
      } else {}
    } catch (e) {
      FirebaseStore.sendError("onUnitySceneLoaded", stacktrace: e.toString());
    }
  }

  // Callback that connects the created controller to the unity controller
  void onUnityCreated(controller) {
    try {
      controller.resume();
      unityWidgetController = controller;
    } catch (e) {
      FirebaseStore.sendError("onUnityCreated", stacktrace: e.toString());
    }
  }

  void changeScene() {
    try {
      Map<String, dynamic> jsonString = {};

      for (var x in gameBloc.levels) {
        if (x.level == lvl) {
          jsonString = x.toJson();
          break;
        }
      }

      String type = jsonString['type'];
      jsonString['powerUp'] = powerUp;
      while (unityWidgetController == null) {
        print("Waiting for unityWidgetController");
      }

      print("Changing level to: $type Portrait");
      jsonString['orientation'] = "Portrait";
      postMessage(jsonString);
    } catch (e) {
      FirebaseStore.sendError("Change Scene Error", stacktrace: e.toString());
    }
  }

  void postMessage(Map<String, dynamic> jsonString) async {
    try {
      while (!unityReady) {
        try {
          unityWidgetController?.postMessage('GameManager', 'CheckReady', 'checkReady');
        } catch (e) {
          print("Unity is not Ready");
        }
        await Future.delayed(const Duration(seconds: 1));
      }
      unityWidgetController!.postJsonMessage('GameManager', 'LoadScene', jsonString);
      changeMusic();
    } catch (e) {
      FirebaseStore.sendError("postMessage", stacktrace: e.toString());
    }
  }

  void showGameOver(bool success) async {
    if (_gameOverReceived) {
      return;
    }
    _gameOverReceived = true;
    await Future.delayed(const Duration(seconds: 3));
    _gameSplash = OverlayEntry(
        opaque: false,
        builder: (BuildContext context) {
          return GameOverSplash(
            success: success,
            onComplete: () {
              _gameSplash.remove();
            },
          );
        });
    Overlay.of(context).insert(_gameSplash);
  }

  void _showGameStartSplash(_) {
    try {
      _gameSplash = OverlayEntry(
          opaque: false,
          builder: (BuildContext context) {
            return GameSplash(
              level: lvl,
              powerup: powerUp.isNotEmpty,
              onComplete: () {
                _gameSplash.remove();
                // allow gesture detection
                changeScene();
              },
            );
          });
      Overlay.of(context).insert(_gameSplash);
    } catch (e) {
      FirebaseStore.sendError("onUnityMessage", stacktrace: e.toString());
    }
  }

  void changeMusic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isMusicOn = prefs.getBool('music') ?? false;
    });
    print("Music: $isMusicOn");
    unityWidgetController!.postMessage('GameManager', 'Music', isMusicOn.toString());
  }
}
