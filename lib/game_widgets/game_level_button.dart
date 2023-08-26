import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_event.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/coins_bloc/coin_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/coins_bloc/coin_event.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/level_bloc/level_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/level_bloc/level_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/bloc_provider.dart';
import '../bloc/game_bloc.dart';
import '../bloc/reporting_bloc/reporting_bloc.dart';
import '../gamification_widgets/advertisement_video_player.dart';

class GameLevelButton extends StatelessWidget {
  const GameLevelButton(
      {Key? key,
      required this.levelNumber,
      this.width = 60.0,
      this.height = 60.0,
      this.borderRadius = 50.0})
      : super(key: key);

  final int levelNumber;
  final double width;
  final double height;
  final double borderRadius;
  final lvlPrice = 500;
  final tntPrice = 100;
  final minePrice = 200;
  final wrappedPrice = 1000;

  @override
  Widget build(BuildContext context) {
    final GameBloc gameBloc = BlocProvider.of<GameBloc>(context);
    final LevelBloc levelBloc = flutter_bloc.BlocProvider.of<LevelBloc>(context);
    final CoinBloc coinBloc = flutter_bloc.BlocProvider.of<CoinBloc>(context);
    final ReportingBloc reportingBloc = flutter_bloc.BlocProvider.of<ReportingBloc>(context);
    final DarkPatternsBloc darkPatternsBloc =
        flutter_bloc.BlocProvider.of<DarkPatternsBloc>(context);
    bool disabled = !levelBloc.state.levels.contains(levelNumber) &&
        darkPatternsBloc.state is DarkPatternsActivatedState;
    Color disabledColor = Colors.grey;

    return InkWell(
      onTap: () async {
        disabled
            ? showBuyLevelDialog(levelBloc, coinBloc, context)
            : showBuyPowerUpDialog(reportingBloc, gameBloc, levelBloc, coinBloc, context);
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 50.0,
          ),
          child: Container(
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: disabled ? disabledColor : Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                width: 0.3,
                color: Colors.black38,
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10.0,
                  offset: Offset(5.0, 5.0),
                  color: Color.fromRGBO(0, 0, 0, 0.3),
                ),
              ],
            ),
            width: width,
            height: height,
            child: Container(
              decoration: BoxDecoration(
                color: disabled ? disabledColor : Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  width: 0.3,
                  color: Colors.black26,
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 1.0,
                    offset: Offset(1.0, 1.5),
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Level $levelNumber',
                  style: const TextStyle(color: Colors.black, fontSize: 16.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openGame(ReportingBloc reportingBloc, GameBloc gameBloc, SharedPreferences prefs,
      BuildContext context) async {
    reportingBloc.add(ReportStartLevelEvent(levelNumber));

    Navigator.of(context).pushNamed(
      "/simple",
      arguments: {'level': levelNumber},
    );
    //ToDo: Put adds before Navigator Push
    var addState = prefs.getBool("addsActive");
    print("Adds are: $addState");
    if (addState == true) {
      _showAdvertisement(context);
    }
  }

  void _showAdvertisement(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AdvertisementVideoPlayer()));
  }

  void showBuyPowerUpDialog(ReportingBloc reportingBloc, GameBloc gameBloc, LevelBloc levelBloc,
      CoinBloc coinBloc, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              // title: const Text('Buy power up?'),
              title: const Text('Start the game'),
              content: Wrap(
                //ToDo: Remove Const, and enable power ups
                children: [
                  const Text('Do you want to buy'),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/bombs/fish_1.png',
                        height: 30,
                      ),
                      Text(' for $tntPrice\$',
                          style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset('assets/images/bombs/rainbow_fish.png', height: 30),
                      Text(' for $minePrice\$',
                          style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ],
              ),
              elevation: 24,
              shape:
                  const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              actions: <Widget>[
                IconButton(
                    icon: Image.asset('assets/images/bombs/fish_1.png'),
                    onPressed: () => buyPowerUp("Clear", tntPrice, coinBloc,
                        reportingBloc, gameBloc, context)),
                IconButton(
                    icon: Image.asset('assets/images/bombs/rainbow_fish.png'),
                    onPressed: () => buyPowerUp("Rainbow", minePrice, coinBloc,
                        reportingBloc, gameBloc, context)),
                TextButton(
                  onPressed: () =>
                      buyPowerUp("", 0, coinBloc, reportingBloc, gameBloc, context),
                  child: const Text('Start Game'),
                )
              ],
            ));
  }

  Future<void> buyPowerUp(item, powerUpPrice, CoinBloc coinBloc, ReportingBloc reportingBloc,
      GameBloc gameBloc, BuildContext context) async {
    if (coinBloc.state.amount >= powerUpPrice) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("powerUp", item);
      coinBloc.add(RemoveCoinsEvent(powerUpPrice));
      Navigator.pop(context, 'OK');
      await openGame(reportingBloc, gameBloc, prefs, context);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Not enough money to buy power up'),
                content:
                    const Text('You can get coins by playing levels or watching advertisements'),
                elevation: 24,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => {Navigator.pop(context, 'Ok')},
                    child: const Text('OK'),
                  )
                ],
              ));
    }
  }

  void showBuyLevelDialog(LevelBloc levelBloc, CoinBloc coinBloc, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => coinBloc.state.amount >= 500
            ? AlertDialog(
                title: Text('Unlock level $levelNumber'),
                content: Text('Do you want to buy level $levelNumber for $lvlPrice\$?'),
                elevation: 24,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => {Navigator.pop(context, 'Cancel')},
                      child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => buyLevel(coinBloc, levelBloc, 'Ok', context),
                    child: const Text('OK'),
                  )
                ],
              )
            : AlertDialog(
                title: const Text('Not enough money to buy level'),
                content:
                    const Text('You can get coins by playing levels or watching advertisements'),
                elevation: 24,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => {Navigator.pop(context, 'Ok')},
                    child: const Text('OK'),
                  )
                ],
              ));
  }

  void buyLevel(CoinBloc coinBloc, LevelBloc levelBloc, String text, BuildContext context) {
    coinBloc.add(RemoveCoinsEvent(lvlPrice));
    levelBloc.add(AddLevelEvent(levelNumber));
    Navigator.pop(context, 'OK');
  }
}
