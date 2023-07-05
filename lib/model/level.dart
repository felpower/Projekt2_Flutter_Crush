///
/// Level
/// 
/// Definition of a level in terms of:
///  - grid template
///  - maximum number of moves
///  - number of columns
///  - number of rows
///
class Level extends Object {
  final int _index;
  final int _rows;
  final int _cols;
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
      resetObjectives();
  }

  int get numberOfRows => _rows;
  int get numberOfCols => _cols;
  int get index => _index;
  int get maxMoves => _maxMoves;
  int get movesLeft => _movesLeft;

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