// ignore_for_file: avoid_print

import 'dart:math';
import 'dart:ui' as ui_web;

import 'package:bachelor_flutter_crush/bloc/game_bloc.dart';
import 'package:bachelor_flutter_crush/helpers/app_colors.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/bloc_provider.dart';
import '../../game_widgets/game_over_splash.dart';
import '../advertisement_video_player.dart';

class FortuneWheel extends StatefulWidget {
  final List<int> items;

  const FortuneWheel({Key? key, required this.items}) : super(key: key);

  @override
  State<FortuneWheel> createState() => _FortuneWheelState();
}

class _FortuneWheelState extends State<FortuneWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late GameBloc gameBloc;
  late Animation<double> _animation;
  final PublishSubject<bool> gameIsOverController = PublishSubject<bool>();
  double _targetRotation = 0.0;
  bool isSpun = false;
  int? _selectedItem;
  late OverlayEntry _gameSplash;

  var _backupButtonVisible = false;

  @override
  void initState() {
    _showPressButton = true;
    super.initState();

    gameBloc = BlocProvider.of<GameBloc>(context);
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));

    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart)
          ..addListener(() {
            setState(() {
              _accumulatedRotation =
                  ui_web.lerpDouble(0, _targetRotation, _animation.value)!;
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              print("Wheel stopped on: $_selectedItem");
              _buildResultOverlay();
            }
          });
  }

  void spin() {
    if (isSpun) return;
    isSpun = true;
    setState(() {
      _showPressButton = false; // Hide the 'Press' button after spinning
    });
    Random random = Random();
    int fullRotations = 5 + random.nextInt(6);
    double randomEndAngle = 2 * pi * random.nextDouble();
    _targetRotation = (fullRotations * 2 * pi) + randomEndAngle;

    _controller.forward(from: 0);

    _selectedItem = widget.items[_calculateSelectedItemIndex()];
    print("Expected item after spin: $_selectedItem");
  }

  int _calculateSelectedItemIndex() {
    double rotationInRadians = _targetRotation % (2 * pi);
    double segmentAngle = 2 * pi / widget.items.length;

    // This calculation determines how many segments are passed during rotation.
    int index =
        ((rotationInRadians / segmentAngle) % widget.items.length).floor();

    // Since the wheel rotates clockwise but items are painted counter-clockwise,
    // we need to invert the index.
    return widget.items.length - 1 - index;
  }

  _buildResultOverlay() {
    if (mounted) {
      // Check if the State object is in a valid context.
      String x = 'Du hast $_selectedItem XP und 🪙 gewonnen. Glückwunsch!';
      setState(() {
        _backupButtonVisible = true;
      });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
                title: Text(x),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _showDarkPatternsInfo();
                    },
                    child: const Text('Weiter'),
                  ),
                ],
              ));
    } else {
      FirebaseStore.sendError("FortuneWheelOverlayError",
          stacktrace: "State object is not in a "
              "valid context. Mounted: $mounted");
    }
  }

  void showGameOver(bool success) {
    // Prevent from bubbling
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Drehe um XP und 🪙 zu erhalten'),
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/background/background_new.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: _buildFortuneWheel(),
              ),
              Visibility(
                  visible: _backupButtonVisible,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        gameBloc.gameOver(_selectedItem!);
                        gameIsOverController.sink.add(true);
                        showGameOver(true);
                      },
                      child: const Text('Weiter'),
                    ),
                  )),
            ],
          ),
        ));
  }

  void _showDarkPatternsInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isExpanded = false;
    var dpInfoShown = prefs.getBool('darkPatternsInfoVAR');

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
                    if (isExpanded)
                      const Text(
                        'Das Glücksrad, das du gerade gedreht hast, ist ein Dark Pattern, welches in vielen Smartphone-Spielen zu finden ist. Es basiert auf dem Prinzip, dass Menschen häufiger zu einem Spiel zurückkehren, wenn sie unvorhersehbare Belohnungen erhalten. Jedes Mal, wenn man das Rad dreht, könnte man eine kleine oder große Belohnung bekommen – oder manchmal gar nichts. Das macht das Ganze besonders spannend, weil man nie weiß, was als Nächstes kommt.\n Hast du bemerkt, dass du öfter das Spiel öffnest, nur um das Glücksrad zu drehen? Fühlst du dich motiviert, es immer wieder zu versuchen, in der Hoffnung, eine größere Belohnung zu bekommen? Genau das ist die Absicht der Spieleentwickler: Sie wollen, dass du länger im Spiel bleibst und vielleicht sogar echtes Geld ausgibst, um weitere Chancen auf Belohnungen zu bekommen.',
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
                      prefs.setBool('darkPatternsInfoVAR', true);
                      Navigator.of(context).pop();
                      Navigator.pop(context);
                      Navigator.pop(context);
                      gameBloc.gameOver(_selectedItem!);
                      gameIsOverController.sink.add(true);
                      showGameOver(true);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AdvertisementVideoPlayer(
                                      isForcedAd: true)));
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      Navigator.pop(context);
      Navigator.pop(context);
      gameBloc.gameOver(_selectedItem!);
      gameIsOverController.sink.add(true);
      showGameOver(true);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const AdvertisementVideoPlayer(
                    isForcedAd: true,
                  )));
    }
  }

  Widget _buildFortuneWheel() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double wheelSize = min(screenWidth, screenHeight) *
        0.8; // Taking 80% of the smaller dimension

    return Center(
      child: GestureDetector(
        onPanEnd: (details) => spin(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: _accumulatedRotation,
              child: CustomPaint(
                size: Size(wheelSize, wheelSize),
                painter: _WheelPainter(widget.items),
              ),
            ),
            const Positioned(
              top: 10,
              child: Icon(Icons.arrow_downward,
                  size: 50, color: Colors.black), // Adjust size/color as needed
            ),
            // Adding a 'Press' box in the middle of the wheel
            if (_showPressButton)
              Container(
                alignment: Alignment.center,
                width: 80,
                // Adjust size as needed
                height: 70,
                // Adjust size as needed
                decoration: BoxDecoration(
                  color: Colors.white, // Adjust color as needed
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Material(
                    type: MaterialType.transparency,
                    // Avoids additional visual effects
                    child: Text(
                      'Tippe Hier!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black, // Adjust text color as needed
                        fontSize: 24, // Adjust font size as needed
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _WheelPainter extends CustomPainter {
  final List<int> items;

  _WheelPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    double wheelRadius = size.width / 2;
    double anglePerItem = 2 * pi / items.length;
    double startAngle = -pi / 2; // Start from the top of the circle

    for (int i = 0; i < items.length; i++) {
      final angle = startAngle + i * anglePerItem;
      final sweepAngle = anglePerItem;

      // Colors
      final rect = Rect.fromCircle(
        center: Offset(wheelRadius, wheelRadius),
        radius: wheelRadius,
      );

      final Paint paint = Paint()
        ..color = AppColors.getColorFortune(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, angle, sweepAngle, true, paint);

      // Draw text
      final textSpan = TextSpan(
        text: items[i].toString(),
        style: const TextStyle(color: Colors.white, fontSize: 20),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Calculate text position
      final labelRadius = wheelRadius - 40; // Adjust this for label positioning
      final xOffset = wheelRadius +
          labelRadius * cos(angle + sweepAngle / 2) -
          textPainter.width / 2;
      final yOffset = wheelRadius +
          labelRadius * sin(angle + sweepAngle / 2) -
          textPainter.height / 2;

      textPainter.paint(canvas, Offset(xOffset, yOffset));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint always for simplicity, optimize if necessary
  }
}

bool _showPressButton =
    true; // New variable to track visibility of the 'Press' button
double _accumulatedRotation =
    0.0; // New variable to store the accumulated rotation over time
