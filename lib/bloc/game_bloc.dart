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

  final PublishSubject<int> _gameIsOverController = PublishSubject<int>();

  Stream<int> get gameIsOver => _gameIsOverController.stream;

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
    _gameIsOverController.close();
  }
}
