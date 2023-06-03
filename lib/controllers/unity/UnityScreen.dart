import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityScreen extends StatefulWidget {
  const UnityScreen({Key? key, required this.level}) : super(key: key);

  final String level;

  @override
  _UnityScreenState createState() => _UnityScreenState();
}

class _UnityScreenState extends State<UnityScreen> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  late UnityWidgetController _unityWidgetController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game'),
      ),
      key: _scaffoldKey,
      body: SafeArea(
        bottom: false,
        child: WillPopScope(
          onWillPop: () {
            return Future(() => true);
          },
          child: Stack(children: <Widget>[
            UnityWidget(
              onUnityCreated: onUnityCreated,
              onUnityMessage: onUnityMessage,
              useAndroidViewSurface: true,
            ),
          ],
          ),
        ),
      ),
    );
  }
  // Callback that connects the created controller to the unity controller
  void onUnityCreated(controller) {
    _unityWidgetController = controller;
    String level = widget.level;
    _unityWidgetController.postMessage('LevelSelect', 'OnButtonPress', level);
    _unityWidgetController.dispose();
    print("Starting level : $level");
  }

  // Communication from Unity to Flutter
  void onUnityMessage(message) {
    print('Received message from unity: ${message.toString()}');
  }

  void onUnitySceneLoaded(SceneLoaded sceneInfo) {
    print('Received scene loaded from unity: ${sceneInfo.name}');
    print('Received scene loaded from unity buildIndex: ${sceneInfo.buildIndex}');
  }

}
