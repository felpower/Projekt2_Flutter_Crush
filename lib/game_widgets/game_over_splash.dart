import 'package:bachelor_flutter_crush/bloc/user_state_bloc/coins_bloc/coin_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/user_state_bloc/coins_bloc/coin_state.dart';
import '../bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import '../bloc/user_state_bloc/xp_bloc/xp_state.dart';
import '../helpers/audio.dart';
import 'double_curved_container.dart';

class GameOverSplash extends StatefulWidget {
  const GameOverSplash({
    Key? key,
    required this.success,
    required this.onComplete,
  }) : super(key: key);

  final VoidCallback onComplete;
  final bool success;

  @override
  _GameOverSplashState createState() => _GameOverSplashState();
}

class _GameOverSplashState extends State<GameOverSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationAppear;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )
      ..addListener(() {
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

    // Play the intro
    Audio.playAsset(AudioType.game_start);

    // Launch the animation
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
    Color darkColor = widget.success ? Colors.green[700]! : Colors.red[700]!;
    Color lightColor = widget.success ? Colors.green : Colors.red;
    String message = widget.success ? "You Win" : "Game Over";

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
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    widget.onComplete();
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: Text(message,
                          style: const TextStyle(
                            fontSize: 35.0,
                            color: Colors.white,
                          )),
                    ),
                    BlocBuilder<DarkPatternsBloc, DarkPatternsState>(
                        builder: (context, state) {
                      if (state is DarkPatternsActivatedState) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BlocBuilder<XpBloc, XpState>(
                                builder: (context, state) {
                              String xpText = state is MultipliedXpState
                                  ? ' x ${state.multiplier}'
                                  : '';
                              return Text(
                                  'Gained XP: ${state.addedAmount}$xpText',
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.white,
                                  ));
                            }),
                            BlocBuilder<CoinBloc, CoinState>(
                                builder: (context, state) {
                              return Text('Gained Coins: ${state.addedAmount}',
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.white,
                                  ));
                            })
                          ],
                        );
                      } else {
                        return Container();
                      }
                    }),
                  ],
                )),
          ),
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
