import 'dart:convert';

import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_event.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/coins_bloc/coin_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/coins_bloc/coin_event.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/level_bloc/level_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/level_bloc/level_event.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

import '../bloc/bloc_provider.dart';
import '../bloc/game_bloc.dart';
import '../bloc/reporting_bloc/reporting_bloc.dart';
import '../controllers/unity/unity_screen.dart';

class GameLevelButton extends StatelessWidget {
  const GameLevelButton(
      {Key? key,
      required this.levelNumber,
      this.width = 60.0,
      this.height = 60.0,
      this.borderRadius = 50.0,
      required this.color,
      required this.buntJelly,
      required this.stripeJelly})
      : super(key: key);

  final int levelNumber;
  final double width;
  final double height;
  final double borderRadius;
  final Color color;
  final int buntJelly;
  final int stripeJelly;

  final lvlPrice = 500;
  static const tntPrice = 100;
  static const minePrice = 200;

  @override
  Widget build(BuildContext context) {
    final GameBloc gameBloc = BlocProvider.of<GameBloc>(context);
    final LevelBloc levelBloc = flutter_bloc.BlocProvider.of<LevelBloc>(context);
    final CoinBloc coinBloc = flutter_bloc.BlocProvider.of<CoinBloc>(context);
    final ReportingBloc reportingBloc = flutter_bloc.BlocProvider.of<ReportingBloc>(context);
    final darkPatternsState = flutter_bloc.BlocProvider.of<DarkPatternsBloc>(context).state;
    bool disabled = !levelBloc.state.levels.contains(levelNumber);

    return InkWell(
      onTap: () {
        disabled
            ? showBuyLevelDialog(levelBloc, coinBloc, darkPatternsState, context)
            : showBuyPowerUpDialog(
                reportingBloc, gameBloc, levelBloc, coinBloc, darkPatternsState, context);
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 50.0,
          ),
          child: Container(
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: disabled ? color.withOpacity(0.5) : color,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                width: 0.3,
                color: color,
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
                color: disabled ? color.withOpacity(0.1) : color,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  width: 0.3,
                  color: color,
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
    try {
      reportingBloc.add(ReportStartLevelEvent(levelNumber));
      Map<String, dynamic>? jsonData;
      for (var x in gameBloc.levels) {
        if (x.level == levelNumber) {
          jsonData = x.toJson();
          break;
        }
      }
      if (jsonData != null) {
        prefs.setString("levelStarted", jsonEncode(jsonData));
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UnityScreen(
                jsonData: jsonData!,
              ),
            ));
      } else {
        throw Exception("Level $levelNumber not found, jsonData is null");
      }
    } catch (e) {
      FirebaseStore.sendError("OpenGameError", stacktrace: e.toString());
    }
  }

  void showBuyPowerUpDialog(ReportingBloc reportingBloc, GameBloc gameBloc, LevelBloc levelBloc,
      CoinBloc coinBloc, DarkPatternsState darkPatternsState, BuildContext context) {
    var darkModeActivated = html.window.matchMedia('(prefers-color-scheme: dark)').matches;
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Sonderjelly Auswahl'),
              content: Wrap(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Um ein Sonderjelly auszuwählen klicke bitte auf den entsprechenden Button '
                      'oder starte das Spiel ohne Sonderjelly indem du auf "Spiel starten" klickst.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: darkModeActivated ? Colors.black : Colors.white), //
                      // Center
                      // align the
                      // text
                    ),
                  )
                ],
              ),
              elevation: 24,
              shape:
                  const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              actions: <Widget>[
                Center(
                  // Center the buttons
                  child: Column(
                    // Use Column to align buttons vertically
                    mainAxisSize: MainAxisSize.min, // Fit the content
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          buyPowerUp("Clear", tntPrice, coinBloc, reportingBloc, gameBloc, context);
                        },
                        icon: Image.asset(
                          'assets/images/bombs/jelly_gelb.png',
                          height: 30,
                        ),
                        label: Text(stripeJelly == 0 ? '$tntPrice\$' : 'kostenlos',
                            style:
                                TextStyle(color: darkModeActivated ? Colors.black : Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          buyPowerUp(
                              "Rainbow", minePrice, coinBloc, reportingBloc, gameBloc, context);
                        },
                        icon: Image.asset('assets/images/bombs/jelly_bunt.png', height: 30),
                        label: Text(buntJelly == 0 ? '$minePrice\$' : 'kostenlos',
                            style:
                                TextStyle(color: darkModeActivated ? Colors.black : Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () =>
                            buyPowerUp("", 0, coinBloc, reportingBloc, gameBloc, context),
                        child: const Text('Spiel starten'),
                      ),
                    ],
                  ),
                ),
              ],
            ));
  }

  Future<void> buyPowerUp(item, powerUpPrice, CoinBloc coinBloc, ReportingBloc reportingBloc,
      GameBloc gameBloc, BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("powerUp", item);
    if (item.contains("Clear") && stripeJelly > 0) {
      prefs.setInt("stripeJelly", stripeJelly - 1);
      FirebaseStore.addItemBought('1 Gestreiftes Sonderjelly');
    } else if (item.contains("Rainbow") && buntJelly > 0) {
      prefs.setInt("buntJelly", buntJelly - 1);
      FirebaseStore.addItemBought("1 Buntes Sonderjelly");
    } else if (coinBloc.state.amount >= powerUpPrice) {
      coinBloc.add(RemoveCoinsEvent(powerUpPrice));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Nicht genug Münzen um dieses Sonderjelly zu kaufen'),
                content: Text(
                    'Du kannst Münzen durch Spielen der Levels erhalten, du benötigst $powerUpPrice\$ um dieses Sonderjelly zu kaufen'),
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
      return;
    }
    Navigator.pop(context, 'OK');
    await openGame(reportingBloc, gameBloc, prefs, context);
  }

  void showBuyLevelDialog(LevelBloc levelBloc, CoinBloc coinBloc,
      DarkPatternsState darkPatternsState, BuildContext context) {
    if (!levelBloc.state.levels.contains(levelNumber - 1)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Du musst zuerst Level ${levelNumber - 1} freischalten'),
          actions: <Widget>[
            TextButton(onPressed: () => {Navigator.pop(context, 'Ok')}, child: const Text('Ok')),
          ],
        ),
      );
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => coinBloc.state.amount >= 500
              ? AlertDialog(
                  title: Text('Level $levelNumber freischalten?'),
                  content: Text('Willst du level $levelNumber für $lvlPrice\$ freischalten?'),
                  elevation: 24,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => {Navigator.pop(context, 'Cancel')},
                        child: const Text('Abbrechen')),
                    TextButton(
                      onPressed: () => {
                        FirebaseStore.addLevelBought(levelNumber),
                        buyLevel(coinBloc, levelBloc, 'Ok', context),
                      },
                      child: const Text('OK'),
                    )
                  ],
                )
              : AlertDialog(
                  title: const Text('Du hast nicht genug Münzen um dieses Level freizuschalten'),
                  content: Text(
                      'Du kannst Münzen durch Spielen der Levels erhalten, du benötigst $lvlPrice\$ um dieses Level freizuschalten'),
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

  void buyLevel(CoinBloc coinBloc, LevelBloc levelBloc, String text, BuildContext context) {
    coinBloc.add(RemoveCoinsEvent(lvlPrice));
    levelBloc.add(AddLevelEvent(levelNumber));
    Navigator.pop(context, 'OK');
  }
}
