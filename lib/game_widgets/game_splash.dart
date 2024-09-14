// ignore_for_file: avoid_print
import 'package:flutter/material.dart';

import 'double_curved_container.dart';

class GameSplash extends StatefulWidget {
  final int level;

  final bool powerup;

  const GameSplash({
    Key? key,
    required this.level,
    required this.powerup,
    required this.onComplete,
  }) : super(key: key);

  final VoidCallback onComplete;

  @override
  State<GameSplash> createState() => _GameSplashState();
}

class _GameSplashState extends State<GameSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationAppear;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.powerup
          ? const Duration(seconds: 6)
          : const Duration(seconds: 4),
      vsync: this,
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          try {
            widget.onComplete();
          } catch (e) {
            print(e);
          }
        }
      });

    _animationAppear = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.1,
          curve: Curves.easeIn,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _animationAppear,
      child: Material(
        color: Colors.transparent,
        child: DoubleCurvedContainer(
          width: screenSize.width,
          height: 150.0,
          outerColor: Colors.blue[700]!,
          innerColor: Colors.blue,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Level:  ${widget.level}',
                  style: const TextStyle(fontSize: 24.0, color: Colors.white),
                ),
                widget.powerup
                    ? const Text(
                        'Vergiss nicht dein gekauftes Sonderjelly zu setzen',
                        style: TextStyle(fontSize: 14.0, color: Colors.white))
                    : Container(),
                const SizedBox(height: 8.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // children: objectiveWidgets,
                ),
              ],
            ),
          ),
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        return Positioned(
          left: 0.0,
          top: 1 + 100.0 * _animationAppear.value,
          child: child!,
        );
      },
    );
  }
}
