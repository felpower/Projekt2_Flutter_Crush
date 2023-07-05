import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/bloc_provider.dart';
import '../../bloc/game_bloc.dart';
import '../../game_widgets/game_over_splash.dart';
import '../../game_widgets/game_splash.dart';

class UnityScreen extends StatefulWidget {
  const UnityScreen({Key? key}) : super(key: key);

  @override
  _UnityScreenState createState() => _UnityScreenState();
}

class _UnityScreenState extends State<UnityScreen> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();


  late GameBloc gameBloc;
  UnityWidgetController? unityWidgetController;
  late OverlayEntry _gameSplash;
  final PublishSubject<bool> _gameIsOverController = PublishSubject<bool>();
  Stream<bool> get gameIsOver => _gameIsOverController.stream;
  late int lvl;
  bool gameOver = false;
  late bool _gameOverReceived;
  bool fabVisible = true;

  late StreamSubscription _gameOverSubscription;
  late List<dynamic> data;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _gameOverReceived = false;
    WidgetsBinding.instance.addPostFrameCallback(_showGameStartSplash);
    readJson();
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
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    lvl = arguments['level'];
    return Scaffold(
      floatingActionButton: PointerInterceptor(
        child: FloatingActionButton(
          child: const Icon(Icons.close),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => PointerInterceptor(
                        child: AlertDialog(
                      title: const Text('Abort level'),
                      content: const Text(
                          'Are you sure you want to abort the level?'),
                      elevation: 24,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () => {Navigator.pop(context, 'Cancel')},
                            child: const Text('No')),
                        TextButton(
                            onPressed: () =>
                                {changeScene("StartScreen"), popUntil()},
                            child: const Text('Yes')),
                      ],
                    )));
          },
        ),
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

  void onUnityMessage(message) {
    print('Received message from unity: ${message.toString()}');
    if (message.startsWith("Score: ")) {
    } else if (message.startsWith("GameOver: Won") && !gameOver) {
      gameBloc.gameOver(lvl);
      _gameIsOverController.sink.add(true);
      gameOver = true;
    } else if (message.startsWith("GameOver: Lost") && !gameOver) {
      gameOver = true;
      gameBloc.gameOver(0);
      _gameIsOverController.sink.add(false);
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

  void changeScene(String level) {
    if (level == "StartScreen") {
      unityWidgetController?.postMessage(
          'GameManager', 'LoadStartScene', level);
      return;
    }
    Map<String, dynamic> jsonString = {};
    for (var x in data) {
      if (x['level'] == lvl) {
        jsonString = x;
        break;
      }
    }

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String type = jsonString['type'];
    if (width > height) {
      print("Changing level to: $type Landscape");
      jsonString['orientation'] = "Landscape";
      unityWidgetController?.postJsonMessage(
          'GameManager', 'LoadScene', jsonString);
    } else {
      print("Changing level to: $type Portrait");
      jsonString['orientation'] = "Portrait";
      unityWidgetController?.postJsonMessage(
          'GameManager', 'LoadScene', jsonString);
    }
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('unityLevels.json');
    data = await json.decode(response)['levels'];
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
            onComplete: () {
              _gameSplash.remove();
              // allow gesture detection
              changeScene("");
            },
          );
        });
    Overlay.of(context).insert(_gameSplash);
  }
}
