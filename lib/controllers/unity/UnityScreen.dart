import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

import '../../game_widgets/game_over_splash.dart';

class UnityScreen extends StatefulWidget {
  const UnityScreen({Key? key, required this.level}) : super(key: key);

  final String level;

  @override
  _UnityScreenState createState() => _UnityScreenState();
}

class _UnityScreenState extends State<UnityScreen> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  UnityWidgetController? _unityWidgetController;
  late OverlayEntry _gameSplash;

  @override
  void initState() {
    super.initState();

    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    // ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _unityWidgetController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Simple Screen'),
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
                onUnityCreated: _onUnityCreated,
                onUnityMessage: onUnityMessage,
                onUnitySceneLoaded: onUnitySceneLoaded,
                useAndroidViewSurface: false,
                borderRadius: const BorderRadius.all(Radius.circular(70)),
              ),
            ],
          )),
    );
  }

  void onUnityMessage(message) {
    print('Received message from unity: ${message.toString()}');
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
  void _onUnityCreated(controller) {
    controller.resume();
    String level = widget.level;
    _unityWidgetController = controller;
    print("Starting level : $level");
  }

  // // Callback that connects the created controller to the unity controller
  // void onUnityCreated(controller) {
  //   controller.resume();
  //   _unityWidgetController = controller;
  //   String level = widget.level;
  //   _unityWidgetController?.postMessage('LevelSelect', 'OnButtonPress', level);
  //   _unityWidgetController?.dispose();
  //   print("Starting level : $level");
  // }
  //
  // // Communication from Unity to Flutter
  // void onUnityMessage(message) {
  //   print('Received message from unity: ${message.toString()}');
  //   if (message.startsWith("Score: ")) {
  //   } else if (message.startsWith("GameOver: Won")) {
  //     showGameOver(true);
  //   } else if (message.startsWith("GameOver: Lost")) {
  //     showGameOver(false);
  //   }
  // }
  //
  // void showGameOver(bool success) {
  //   _gameSplash = OverlayEntry(
  //       opaque: false,
  //       builder: (BuildContext context) {
  //         return GameOverSplash(
  //           success: success,
  //           onComplete: () {
  //             _gameSplash.remove();
  //             Navigator.of(context).pop();
  //           },
  //         );
  //       });
  // }
  //
  // void onUnitySceneLoaded(SceneLoaded? scene) {
  //   if (scene != null) {
  //     print('Received scene loaded from unity: ${scene.name}');
  //     print('Received scene loaded from unity buildIndex: ${scene.buildIndex}');
  //   } else {
  //     print('Received scene loaded from unity: null');
  //   }
  // }
}
