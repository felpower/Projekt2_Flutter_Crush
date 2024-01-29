// ignore_for_file: avoid_print

import 'dart:async';

import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/level_bloc/level_event.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:just_audio/just_audio.dart';
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
  const UnityScreen({Key? key, required this.jsonData}) : super(key: key);

  final Map<String, dynamic> jsonData;

  @override
  State<UnityScreen> createState() => _UnityScreenState();
}

class _UnityScreenState extends State<UnityScreen> {
  AudioPlayer backgroundAudio = AudioPlayer();
  AudioPlayer wonLostAudio = AudioPlayer();
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
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      _gameOverReceived = false;
      WidgetsBinding.instance.addPostFrameCallback(_showGameStartSplash);
      loadCoins();
      levelBloc = flutter_bloc.BlocProvider.of<LevelBloc>(context);
      darkPatternsBloc = flutter_bloc.BlocProvider.of<DarkPatternsBloc>(context);
    } catch (e, s) {
      print('Caught error: $e');
      print('Stacktrace: $s');
      FirebaseStore.sendError(e.toString(), stacktrace: s.toString());
    }
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
    stopMusic();
    _gameOverSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      lvl = widget.jsonData['level'];
      coinBloc = flutter_bloc.BlocProvider.of<CoinBloc>(context);
      return PopScope(
          canPop: false,
          child: Scaffold(
            floatingActionButton: PointerInterceptor(
              child: Visibility(
                  visible: unityReady && !gameOver,
                  child: FloatingActionButton(
                    heroTag: 'closeFAB',
                    backgroundColor: Colors.transparent,
                    child: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      try {
                        FirebaseStore.sendLog("closeFAB", "Close FAB pressed");
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
                      } catch (e) {
                        FirebaseStore.sendError("closeFABError", stacktrace: e.toString());
                      }
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
                        onUnityUnloaded: onUnityUnloaded,
                        printSetupLog: false,
                        layoutDirection: TextDirection.ltr,
                        fullscreen: true,
                        hideStatus: true)),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: PointerInterceptor(
                        child: FloatingActionButton(
                      heroTag: 'musicFAB',
                      backgroundColor: Colors.transparent,
                      elevation: 0.0,
                      onPressed: () async {
                        FirebaseStore.sendLog("musicFab", "Music FAB pressed");
                        try {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          setState(() {
                            isMusicOn = !isMusicOn;
                            prefs.setBool('music', isMusicOn);
                            changeMusic();
                          });
                        } catch (e) {
                          FirebaseStore.sendError("musicFABError", stacktrace: e.toString());
                        }
                      },
                      child: isMusicOn ? const Icon(Icons.music_note) : const Icon(Icons.music_off),
                    )),
                  ),
                ),
              ],
            ),
          ));
    } catch (e, s) {
      print('Caught error: $e');
      print('Stacktrace: $s');
      FirebaseStore.sendError(e.toString(), stacktrace: s.toString());
      return Center(
        child: Text(
          'An error occurred, please check the logs for more details. Stacktrace: $s, Error: $e',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }

  void popUntil() {
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  int star = 0;

  void shuffleDialog() {
    if (!gameOver) {
      showDialog(
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
                                  postUnityMessage('Level', 'ShufflePieces', "ShufflePieces"),
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
                    )));
    }
  }

  void gameWon(message) {
    try {
      levelBloc.add(AddLevelEvent(lvl + 1));
      playWonLostMusic(true);
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
    } catch (e) {
      FirebaseStore.sendError("gameWonError", stacktrace: e.toString());
    }
  }

  void showFortuneWheel(int xpCoins) async {
    try {
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
    } catch (e) {
      FirebaseStore.sendError("showFortuneWheelError", stacktrace: e.toString());
    }
  }

  void gameLost() {
    try {
      setState(() {
        fabVisible = false;
      });
      playWonLostMusic(false);
      gameOver = true;
      gameBloc.gameOver(0);
      _gameIsOverController.sink.add(false);
      showGameOver(false);
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pop();
      });
    } catch (e) {
      FirebaseStore.sendError("gameLostError", stacktrace: e.toString());
    }
  }

  void onUnityMessage(message) {
    try {
      print("Message received: $message");
      if (message.startsWith("checkReady")) {
        print("Message received Unity is ready");
        setState(() {
          unityReady = true;
        });
        changeMusic();
      }
      if (!unityReady) {
        return;
      }
      if (message.startsWith("Resend Level Info")) {
        FirebaseStore.sendLog("ResendLevelInfo", message);
        changeScene();
        return;
      }
      if (message.startsWith("Score: ")) {
        return;
      } else if (message.startsWith("Shuffle")) {
        FirebaseStore.sendLog("Shuffle", message);
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
      if (!unityReady) {
        FirebaseStore.sendLog("onUnitySceneLoaded", "Unity not ready");
        return;
      }
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
      checkUnityReady();
    } catch (e) {
      FirebaseStore.sendError("onUnityCreated", stacktrace: e.toString());
    }
  }

  void changeScene() {
    try {
      Map<String, dynamic> jsonString = widget.jsonData;
      String type = jsonString['type'];
      jsonString['powerUp'] = powerUp;
      while (unityWidgetController == null) {
        print("Waiting for unityWidgetController");
      }

      print("Changing level to: $type Portrait");
      jsonString['orientation'] = "Portrait";
      postUnityMessageJson(jsonString);
    } catch (e) {
      FirebaseStore.sendError("ChangeSceneError", stacktrace: e.toString());
    }
  }

  void postUnityMessage(String gameObject, String methodName, message) async {
    try {
      if (!unityReady) {
        print("Unity not ready still trying to post message");
        FirebaseStore.sendError("postUnityMessageError",
            stacktrace: "Unity not ready still trying to post message ");
      }
      unityWidgetController?.postMessage(gameObject, methodName, message);
    } catch (e) {
      FirebaseStore.sendError("postUnityMessageError", stacktrace: e.toString());
    }
  }

  void postUnityMessageJson(Map<String, dynamic> jsonString) async {
    try {
      if (!unityReady) {
        print("Unity not ready still trying to post message Json");
        FirebaseStore.sendError("postUnityMessageJsonError",
            stacktrace: "Unity not ready still trying to post message Json");
      }
      unityWidgetController?.postJsonMessage('GameManager', 'LoadScene', jsonString);
    } catch (e) {
      FirebaseStore.sendError("postUnityMessageJsonError", stacktrace: e.toString());
    }
  }

  void checkUnityReady() async {
    while (!unityReady) {
      try {
        unityWidgetController?.postMessage('GameManager', 'CheckReady', 'checkReady');
        print("Check Unity is Ready");
      } catch (e) {
        print("Unity is not Ready");
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void showGameOver(bool success) async {
    try {
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
    } catch (e) {
      FirebaseStore.sendError("showGameOverError", stacktrace: e.toString());
    }
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
      FirebaseStore.sendError("showGameStartSplashError", stacktrace: e.toString());
    }
  }

  void changeMusic() async {
    try {
      if (!unityReady) {
        print("changeMusicError stacktrace: Unity not ready");
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        isMusicOn = prefs.getBool('music') ?? false;
      });
      print("Music: $isMusicOn");
      if (isMusicOn) {
        playBackgroundMusic();
      } else {
        stopMusic();
      }
    } catch (e) {
      FirebaseStore.sendError("changeMusicError", stacktrace: e.toString());
    }
  }

  void onUnityUnloaded() {
    try {
      if (!unityReady) {
        return;
      }
      unityWidgetController!.pause();
      FirebaseStore.sendLog("onUnityUnloaded", "Unity unloaded");
    } catch (e) {
      FirebaseStore.sendError("onUnityUnloadedError", stacktrace: e.toString());
    }
  }

  void playBackgroundMusic() async {
    await backgroundAudio.setAsset('assets/audio/Background_Music.mp3');
    backgroundAudio.play();
  }

  void stopMusic() async {
    await backgroundAudio.stop();
  }

  void playWonLostMusic(bool won) {
    stopMusic();
    if (!isMusicOn) {
      return;
    }
    if (won) {
      wonLostAudio.setAsset('assets/audio/winning_music.mp3');
    } else {
      wonLostAudio.setAsset('assets/audio/losing_music.mp3');
    }
    wonLostAudio.play();
  }
}
