// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import '../model/level.dart';
import 'bloc_provider.dart';

class GameBloc implements BlocBase {
  static final GameBloc _gameBloc = GameBloc._internal();

  factory GameBloc() {
    _gameBloc._loadLevels();
    return _gameBloc;
  }

  GameBloc._internal();

  // Max number of tiles per row (and per column)
  static double kMaxTilesPerRowAndColumn = 12.0;
  static double kMaxTilesSize = 28.0;

  //
  // Controller that emits a boolean value to trigger the display of the tiles
  // at game load is ready.  This is done as soon as this BLoC receives the
  // dimensions/position of the board as well as the dimensions of a tile
  //
  final BehaviorSubject<bool> _readyToDisplayTilesController = BehaviorSubject<bool>();

  Function get setReadyToDisplayTiles => _readyToDisplayTilesController.sink.add;

  Stream<bool> get outReadyToDisplayTiles => _readyToDisplayTilesController.stream;

  //
  // Controller aimed at processing the Objective events
  //

  //
  // Controller that emits a boolean value to notify that a game is over
  // the boolean value indicates whether the game is won (=true) or lost (=false)
  //
  final PublishSubject<int> _gameIsOverController = PublishSubject<int>();

  Stream<int> get gameIsOver => _gameIsOverController.stream;

  //
  // Controller that emits the number of moves left for the game
  //
  final PublishSubject<int> _movesLeftController = PublishSubject<int>();

  Stream<int> get movesLeftCount => _movesLeftController.stream;

  final PublishSubject<int> _maxLevelNumber = PublishSubject<int>();

  Stream<int> get maxLevelNumber => _maxLevelNumber.stream;

  //
  // List of all level definitions
  //
  final List<Level> _levels = <Level>[];
  int _maxLevel = 0;

  bool gameAlreadyOver = false;

  List<Level> get levels => _levels;

  // Load the levels definitions from assets
  //
  _loadLevels() async {
    String jsonContent = "";
    try {
      jsonContent = await rootBundle.loadString('unityLevels.json');
    } catch (e) {
      print('jsonContent after levels still empty: $e');
    }
    if (jsonContent.isEmpty ||
        jsonContent.startsWith("<!DOCTYPE html>") ||
        jsonContent.startsWith("<html>")) {
      jsonContent = await rootBundle.loadString('assets/unityLevels.json');
    }
    Map<dynamic, dynamic> list = json.decode(jsonContent);
    (list["levels"]).forEach((levelItem) {
      _levels.add(Level.fromJson(levelItem));
    });
    _maxLevel = _levels.last.level;
    _maxLevelNumber.add(_maxLevel);
  }

  void gameOver(int xp) {
    _gameIsOverController.sink.add(xp);
  }

  @override
  void dispose() {
    _readyToDisplayTilesController.close();
    _gameIsOverController.close();
    _movesLeftController.close();
  }
}
