import 'package:quiver/async.dart';

import '../helpers/array_2d.dart';
import 'objective.dart';

///
/// Level
/// 
/// Definition of a level in terms of:
///  - grid template
///  - maximum number of moves
///  - number of columns
///  - number of rows
///  - list of objectives
///
class Level extends Object {
  final int _index;
  late Array2d grid;
  final int _rows;
  final int _cols;
  final List<Objective> _objectives = [];
  final int _maxMoves;
  int _movesLeft = 0;

  //
  // Variables that depend on the physical layout of the device
  //
  double tileWidth = 0.0;
  double tileHeight = 0.0;
  double boardLeft = 0.0;
  double boardTop = 0.0;

  Level.fromJson(Map<String, dynamic> json)
    : _index = json["level"],
      _rows = json["xDim"],
      _cols = json["yDim"],
      _maxMoves = json["numMoves"]
    {
      // Initialize the grid to the dimensions
      grid = Array2d(_rows, _cols);

      // Populate the grid from the definition
        //
        // Trick
        //  As the definition in the JSON file defines the 
        //  rows (top-down) and also because we are recording
        //  the grid (bottom-up), we need to reverse the
        //  definition from the JSON file.
        //

      // Retrieve the objectives
      // First-time initialization
      resetObjectives();
  }

  @override
  String toString(){
    return "level: $index \n" + dumpArray2d(grid);
  }

  int get numberOfRows => _rows;
  int get numberOfCols => _cols;
  int get index => _index;
  int get maxMoves => _maxMoves;
  int get movesLeft => _movesLeft;
  List<Objective> get objectives => List.unmodifiable(_objectives);

  //
  // Reset the objectives
  //
  void resetObjectives(){
  }

  //
  // Decrement the number of moves left
  //
  int decrementMove(){
    return (--_movesLeft).clamp(0, _maxMoves);
  }
}