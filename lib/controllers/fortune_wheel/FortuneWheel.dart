import 'dart:math';
import 'dart:ui';

import 'package:bachelor_flutter_crush/bloc/game_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/src/subjects/publish_subject.dart';

import '../../game_widgets/game_over_splash.dart';

class FortuneWheel extends StatefulWidget {
  final List<int> items;

  final GameBloc gameBloc;

  final PublishSubject<bool> gameIsOverController;

  const FortuneWheel(
      {Key? key, required this.items, required this.gameBloc, required this.gameIsOverController})
      : super(key: key);

  @override
  State<FortuneWheel> createState() => _FortuneWheelState();
}

class _FortuneWheelState extends State<FortuneWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _animation;

  double _targetRotation = 0.0;
  double _accumulatedRotation = 0.0; // New variable to store the accumulated rotation over time
  bool isSpun = false;
  int? _selectedItem;
  bool showResult = false;

  late OverlayEntry _gameSplash;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5));

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart)
      ..addListener(() {
        setState(() {
          _accumulatedRotation = lerpDouble(0, _targetRotation, _animation.value)!;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Here, _selectedItem has the value on which the wheel stopped.
          print("Wheel stopped on: $_selectedItem");
          showResult = true;

          // If you want to notify some other part of the app,
          // you can use a callback or some other state management solution here.
        }
      });
  }

  void spin() {
    if (isSpun) return;
    isSpun = true;

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
    int index = ((rotationInRadians / segmentAngle) % widget.items.length).floor();

    // Since the wheel rotates clockwise but items are painted counter-clockwise,
    // we need to invert the index.
    return widget.items.length - 1 - index;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildFortuneWheel(),
        if (showResult) _buildResultOverlay(),
      ],
    );
  }

  Widget _buildResultOverlay() {
    return Center(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.7), // This gives a semi-transparent background.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _selectedItem != 0
                  ? 'You won $_selectedItem XP. Congratulations!'
                  : 'Better luck next time!',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.gameBloc.gameOver(_selectedItem!);
                widget.gameIsOverController.sink.add(true);
                showGameOver(true);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  void showGameOver(bool success) async {
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

  Widget _buildFortuneWheel() {
    return Container(
        color: Colors.black,
        child: Center(
            child: GestureDetector(
          onTap: spin,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double size =
                  constraints.biggest.shortestSide; // Use the shortest side to determine the size
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1, // To maintain a square shape
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: CustomPaint(
                          painter:
                              _WheelPainter(items: widget.items, rotation: _accumulatedRotation),
                        ),
                      ),
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.arrow_back, size: 40, color: Colors.red),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        )));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _WheelPainter extends CustomPainter {
  final List<int> items;
  final double rotation;

  _WheelPainter({required this.items, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final double itemAngle = 2 * pi / items.length;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    for (int i = 0; i < items.length; i++) {
      final startAngle = i * itemAngle + rotation;
      final sweepAngle = itemAngle;
      final paint = Paint()
        ..color = Colors.primaries[i % Colors.primaries.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, paint);

      // Drawing text can be more complex, depending on your design.
      // This is a basic way to position the text on each slice:
      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i].toString(),
          style: const TextStyle(color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final position = Offset(
        center.dx +
            (size.shortestSide / 4) * cos(startAngle + sweepAngle / 2) -
            textPainter.width / 2,
        center.dy +
            (size.shortestSide / 4) * sin(startAngle + sweepAngle / 2) -
            textPainter.height / 2,
      );
      textPainter.paint(canvas, position);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
