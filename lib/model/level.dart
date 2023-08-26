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
  final int level;
  final String type;
  final int xDim;
  final int yDim;
  final int numMoves;
  final int score1;
  final int score2;

  final int score3;

  final int targetScore;
  final int timeInSeconds;
  final int numOfObstacles;

  final List<dynamic> obstacleTypes;

  Level.fromJson(Map<String, dynamic> json)
      : level = json["level"],
        type = json["type"],
        xDim = json["xDim"],
        yDim = json["yDim"],
        numMoves = json["numMoves"],
        score1 = json["score1"],
        score2 = json["score2"],
        score3 = json["score3"],
        targetScore = json["targetScore"],
        timeInSeconds = json["timeInSeconds"],
        numOfObstacles = json["numOfObstacles"],
        obstacleTypes = json["obstacleTypes"] {
    resetObjectives();
  }

  int get numberOfRows => xDim;

  int get numberOfCols => yDim;

  int get index => level;

  int get maxMoves => numMoves;

  //
  // Reset the objectives
  //
  void resetObjectives() {}

  @override
  String toString() {
    return 'Level{level: $level, type: $type, xDim: $xDim, yDim: $yDim, numMoves: $numMoves, score1: $score1, score2: $score2, score3: $score3, targetScore: $targetScore, timeInSeconds: $timeInSeconds, numOfObstacles: $numOfObstacles, obstacleTypes: $obstacleTypes}';
  }

  Map<String, dynamic> toJson() {
    return {
      "level": level,
      "type": type,
      "xDim": xDim,
      "yDim": yDim,
      "numMoves": numMoves,
      "score1": score1,
      "score2": score2,
      "score3": score3,
      "targetScore": targetScore,
      "timeInSeconds": timeInSeconds,
      "numOfObstacles": numOfObstacles,
      "obstacleTypes": obstacleTypes
    };
  }
}
