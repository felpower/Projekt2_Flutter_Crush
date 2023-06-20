import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
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
  UnityWidgetController? unityWidgetController;
  late OverlayEntry _gameSplash;
  late String levelName;
  late String level;
  bool gameOver = false;
  bool fabVisible = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback(_showGameStartSplash);
  }

  @override
  dispose() {
    unityWidgetController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    int lvl = arguments['level'];
    levelName = "Level $lvl";
    lvl = lvl % 4 + 1;
    level = "Level0$lvl";
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
                            onPressed: () => {popUntil()},
                            child: const Text('Yes')),
                      ],
                    )));
          },
        ),
      ),
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(levelName),
      ),
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
      gameOver = true;
      showGameOver(true);
    } else if (message.startsWith("GameOver: Lost") && !gameOver) {
      gameOver = true;
      showGameOver(false);
    }
  }

  void onUnitySceneLoaded(SceneLoaded? scene) {
    if (scene != null) {
      print('Received scene loaded from unity: ${scene.name}');
      print('Received scene loaded from unity buildIndex: ${scene.buildIndex}');
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    print("Width: $width Height: $height");
    if (width> height) {
      print("Changing level to: $level");
      unityWidgetController?.postMessage('GameManager', 'LoadScene', level);
    } else {
      print("Changing level to: $level Portrait");
      unityWidgetController?.postMessage('GameManager', 'LoadScene', "${level}Portrait");
    }
  }

  void showGameOver(bool success) {
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
    // No gesture detection during the splash

    // Show the splash
    _gameSplash = OverlayEntry(
        opaque: false,
        builder: (BuildContext context) {
          return GameSplash(
            onComplete: () {
              _gameSplash.remove();
              // allow gesture detection
              changeScene(level);
            },
          );
        });
    Overlay.of(context).insert(_gameSplash);
  }
}
