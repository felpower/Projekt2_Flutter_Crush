import 'package:flutter/material.dart';

import '../game_widgets/double_curved_container.dart';

class DayStreakMilestoneReachedSplash extends StatefulWidget {
  final int daystreak;
  final int coins;
  final VoidCallback onComplete;

  const DayStreakMilestoneReachedSplash(
      this.daystreak, this.coins, this.onComplete,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _GameStreakMilestoneReachedSplashState();
}

class _GameStreakMilestoneReachedSplashState
    extends State<DayStreakMilestoneReachedSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationAppear;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..addListener(() {
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
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
    Color darkColor = Colors.purple[700]!;
    Color lightColor = Colors.purple;
    String message = 'You reached a daystreak milestone!';
    return AnimatedBuilder(
      animation: _animationAppear,
      child: Material(
        color: Colors.transparent,
        child: DoubleCurvedContainer(
          width: screenSize.width,
          height: 150.0,
          outerColor: darkColor,
          innerColor: lightColor,
          child: Container(
              color: lightColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(message,
                        style: const TextStyle(
                          fontSize: 22.0,
                          color: Colors.white,
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Reached DayStreak: ' + widget.daystreak.toString(),
                          style: const TextStyle(
                            fontSize: 15.0,
                            color: Colors.white,
                          )),
                      Text('Gained Coins: ' + widget.coins.toString(),
                          style: const TextStyle(
                            fontSize: 15.0,
                            color: Colors.white,
                          ))
                    ],
                  )
                ],
              )),
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        return Positioned(
          left: 0.0,
          top: 150.0 + 100.0 * _animationAppear.value,
          child: child!,
        );
      },
    );
  }
}
