import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/bloc_provider.dart';
import '../../bloc/game_bloc.dart';
import '../../bloc/user_state_bloc/coins_bloc/coin_bloc.dart';
import '../../bloc/user_state_bloc/coins_bloc/coin_event.dart';
import '../../game_widgets/game_over_splash.dart';
import '../../game_widgets/game_splash.dart';

int coins = 0;

class UnityScreen extends StatefulWidget {
  const UnityScreen({Key? key}) : super(key: key);

  @override
  State<UnityScreen> createState() => _UnityScreenState();
}

class _UnityScreenState extends State<UnityScreen> {
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late GameBloc gameBloc;
  UnityWidgetController? unityWidgetController;
  late OverlayEntry _gameSplash;
  final PublishSubject<bool> _gameIsOverController = PublishSubject<bool>();
  late CoinBloc coinBloc;
  int shufflePrice = 20;
  bool unityReady = false;
  String powerUp = "";

  Stream<bool> get gameIsOver => _gameIsOverController.stream;
  late int lvl;
  bool gameOver = false;
  late bool _gameOverReceived;
  bool fabVisible = true;

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
  }

  void loadCoins() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = (prefs.getInt('coin') ?? 10);
      powerUp = (prefs.getString("powerUp") ?? "");
      print("Coins: $coins");
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
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    lvl = arguments['level'];
    coinBloc = flutter_bloc.BlocProvider.of<CoinBloc>(context);
    return Scaffold(
      floatingActionButton: PointerInterceptor(
        child: Visibility(
            visible: !gameOver,
            child: FloatingActionButton(
              child: const Icon(Icons.close),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => PointerInterceptor(
                            child: AlertDialog(
                          title: const Text('Abort level'),
                          content: const Text('Are you sure you want to abort the level?'),
                          elevation: 24,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(16))),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () => {Navigator.pop(context, 'Cancel')},
                                child: const Text('No')),
                            TextButton(onPressed: () => {popUntil()}, child: const Text('Yes')),
                          ],
                        )));
              },
            )),
      ),
      key: _scaffoldKey,
      body: Card(
          margin: const EdgeInsets.all(0),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Stack(
            children: [
              UnityWidget(
                onUnityCreated: onUnityCreated,
                onUnityMessage: onUnityMessage,
                onUnitySceneLoaded: onUnitySceneLoaded,
                useAndroidViewSurface: false,
                borderRadius: const BorderRadius.all(Radius.circular(70)),
              ),
            ],
          )),
    );
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
                        title: const Text('No More moves possible'),
                        content: Text(
                            'Do you want to spend $shufflePrice coins for a shuffle? You currently have '
                            '$coins '
                            'coins.'),
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
                              child: const Text('Yes')),
                          TextButton(
                              onPressed: () => {
                                    star > 0 ? gameWon(star) : gameLost(),
                                    Navigator.of(context).pop()
                                  },
                              child: const Text('Game Over')),
                        ],
                      )
                    : AlertDialog(
                        title: const Text('No More moves possible'),
                        content: Text(
                            'You have insufficient coins ($shufflePrice) for a shuffle? You currently have '
                            '$coins coins. You just lost the game'),
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
    var xpCoins = 0;
    if (message is int) {
      xpCoins = lvl * message;
    } else {
      xpCoins = lvl * int.parse(message.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    gameBloc.gameOver(xpCoins);
    _gameIsOverController.sink.add(true);
    gameOver = true;
    return;
  }

  void gameLost() {
    gameOver = true;
    gameBloc.gameOver(0);
    _gameIsOverController.sink.add(false);
    return;
  }

  void onUnityMessage(message) {
    print('Received message from unity: ${message.toString()}');
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
      gameWon(message);
    } else if (message.startsWith("GameOver: Lost") && !gameOver) {
      gameLost();
    } else if (message.startsWith("Reached Star:")) {
      star = int.parse(message.replaceAll(RegExp(r'[^0-9]'), ''));
    }
  }

  void onUnitySceneLoaded(SceneLoaded? scene) {
    if (scene != null) {
      print('Received scene loaded from unity: ${scene.name}');
    } else {
      print('Received scene loaded from unity: null');
    }
  }

  // Callback that connects the created controller to the unity controller
  void onUnityCreated(controller) {
    controller.resume();
    unityWidgetController = controller;
  }

  void changeScene() {
    Map<String, dynamic> jsonString = {};

    for (var x in gameBloc.levels) {
      if (x.level == lvl) {
        jsonString = x.toJson();
        break;
      }
    }

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String type = jsonString['type'];
    jsonString['powerUp'] = powerUp;
    while (unityWidgetController == null) {
      print("Waiting for unityWidgetController");
    }
    if (width > height) {
      print("Changing level to: $type Landscape");
      jsonString['orientation'] = "Landscape";
      postMessage(jsonString);
    } else {
      print("Changing level to: $type Portrait");
      jsonString['orientation'] = "Portrait";
      print(jsonString.toString());
      postMessage(jsonString);
    }
  }

  void postMessage(Map<String, dynamic> jsonString) async {
    print("Check if Unity is Ready");
    while (!unityReady) {
      try {
        unityWidgetController?.postMessage('GameManager', 'CheckReady', 'checkReady');
      } catch (e) {
        print("Unity is not Ready");
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    print("Unity is Ready");
    unityWidgetController!.postJsonMessage('GameManager', 'LoadScene', jsonString);
  }

  void showGameOver(bool success) async {
    // Prevent from bubbling
    if (_gameOverReceived) {
      return;
    }
    _gameOverReceived = true;
    _gameSplash = OverlayEntry(
        opaque: false,
        builder: (BuildContext context) {
          return GameOverSplash(
            success: success,
            onComplete: () {
              _gameSplash.remove();
              Navigator.of(context).pop();
            },
          );
        });
    setState(() {
      fabVisible = false;
    });
    Overlay.of(context).insert(_gameSplash);
  }

  void _showGameStartSplash(_) {
    _gameSplash = OverlayEntry(
        opaque: false,
        builder: (BuildContext context) {
          return GameSplash(
            level: lvl,
            onComplete: () {
              _gameSplash.remove();
              // allow gesture detection
              changeScene();
            },
          );
        });
    Overlay.of(context).insert(_gameSplash);
  }
}
