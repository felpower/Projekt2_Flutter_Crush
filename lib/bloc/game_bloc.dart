import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/game_controller.dart';
import '../model/level.dart';
import '../model/objective.dart';
import 'objective_bloc/objective_event.dart';
import '../model/tile.dart';
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
  final BehaviorSubject<bool> _readyToDisplayTilesController =
      BehaviorSubject<bool>();

  Function get setReadyToDisplayTiles =>
      _readyToDisplayTilesController.sink.add;

  Stream<bool> get outReadyToDisplayTiles =>
      _readyToDisplayTilesController.stream;

  //
  // Controller aimed at processing the Objective events
  //
  final PublishSubject<ObjectiveEvent> _objectiveEventsController =
      PublishSubject<ObjectiveEvent>();

  Function get sendObjectiveEvent => _objectiveEventsController.sink.add;

  Stream<ObjectiveEvent> get outObjectiveEvents =>
      _objectiveEventsController.stream;

  //
  // Controller that emits a boolean value to notify that a game is over
  // the boolean value indicates whether the game is won (=true) or lost (=false)
  //
  final PublishSubject<bool> _gameIsOverController = PublishSubject<bool>();

  Stream<bool> get gameIsOver => _gameIsOverController.stream;

  //
  // Controller that emits the number of moves left for the game
  //
  final PublishSubject<int> _movesLeftController = PublishSubject<int>();

  Stream<int> get movesLeftCount => _movesLeftController.stream;

  final PublishSubject<int> _maxLevelNumber = PublishSubject<int>();
  Stream<int> get maxLevelNumber => _maxLevelNumber.stream;

  final PublishSubject<GameController> _streamGameController = PublishSubject<GameController>();
  Stream<GameController> get streamGameController => _streamGameController.stream;

  //
  // List of all level definitions
  //
  final List<Level> _levels = <Level>[];
  int _maxLevel = 0;
  int _levelNumber = 0;
  int get levelNumber => _levelNumber;
  int get numberOfLevels => _maxLevel;

  bool gameAlreadyOver = false;


  //
  // The Controller for the Game being played
  //
  late GameController _gameController;

  GameController get gameController => _gameController;

  //
  // The user wants to select a level.
  // We validate the level number and emit the requested Level
  //
  // We use the [async] keyword to allow the caller to use a Future
  //
  //  e.g.  bloc.setLevel(1).then(() => )
  //
  Future<Level> setLevel(int levelIndex) async {
    gameAlreadyOver = false;
    _levelNumber = (levelIndex - 1).clamp(0, _maxLevel);

    //
    // Initialize the Game
    //
    _gameController = GameController(level: _levels[_levelNumber]);
    _streamGameController.sink.add(_gameController);

    //
    // Fill the Game with Tile and make sure there are possible Swaps
    //
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _gameController.shuffle(prefs.getString('powerUp') ?? 'nothing');

    return _levels[_levelNumber];
  }

  //
  // Load the levels definitions from assets
  //
  _loadLevels() async {
    String jsonContent = await rootBundle.loadString("assets/levels.json");
    Map<dynamic, dynamic> list = json.decode(jsonContent);
    (list["levels"]).forEach((levelItem) {
      _levels.add(Level.fromJson(levelItem));
      _maxLevel++;
    });
    _maxLevelNumber.add(_maxLevel);
  }

  //
  // A certain number of tiles have been removed (or created)
  // We need to notify anyone who might be interested in
  // knowing it so that actions can be taken
  //
  void pushTileEvent(TileType tileType, int counter) {
    // We first need to decrement the objective by the counter
    try {
      Objective objective =
          gameController.level.objectives.firstWhere((o) => o.type == tileType);
      //if (objective == null) { return; }

      objective.decrement(counter);

      // Send a notification
      sendObjectiveEvent(
          ObjectiveEvent(type: tileType, remaining: objective.count));

      // Check if the game is won
      if (!gameAlreadyOver) {
        gameAlreadyOver = true;
        bool isWon = true;
        for (var objective in gameController.level.objectives) {
          if (objective.count > 0) {
            isWon = false;
            gameAlreadyOver = false;
          }
        }

        // If the game is won, send a notification
        if (isWon) {
          _gameIsOverController.sink.add(true);
        }
      }
    } catch (e) {
      return;
    }
  }

  //
  // A move has been played, let's decrement the number of moves
  // left and check if the game is over
  //
  void playMove() {
    int movesLeft = gameController.level.decrementMove();

    // Emit the number of moves left (to refresh the moves left panel)
    _movesLeftController.sink.add(movesLeft);

    // There is no move left, so inform that the game is over
    if (movesLeft == 0) {
      _gameIsOverController.sink.add(false);
    }
  }

  //
  // When a game starts, we need to reset everything
  //
  void reset() {
    gameController.level.resetObjectives();
  }

  @override
  void dispose() {
    _readyToDisplayTilesController.close();
    _objectiveEventsController.close();
    _gameIsOverController.close();
    _movesLeftController.close();
  }
}
