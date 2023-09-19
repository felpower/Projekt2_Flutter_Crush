namespace Match3 {
	public class LevelObstacles : Level {
		private const int ScorePerPieceCleared = 1000;

		public int numMoves;
		public PieceType[] obstacleTypes;

		private int _movesUsed;
		private int _numObstaclesLeft;

		private void Start() {
			var sceneInfo = SceneInfoExtensions.GetAsSceneInfo();
			if (!string.IsNullOrEmpty(sceneInfo.level)) {
				Setup(sceneInfo);
				numMoves = sceneInfo.numMoves;
			}

			type = LevelType.Obstacle;
			foreach (var obstacleType in obstacleTypes)
				_numObstaclesLeft += gameGrid.GetPiecesOfType(obstacleType).Count;

			hud.SetLevelType(type);
			hud.SetScore(currentScore);
			hud.SetTarget(_numObstaclesLeft);
			hud.SetRemaining(numMoves);
		}

		public override void OnMove() {
			_movesUsed++;

			hud.SetRemaining(numMoves - _movesUsed);

			if (numMoves - _movesUsed == 0 && _numObstaclesLeft > 0) GameLose();
		}

		public override void OnPieceCleared(GamePiece piece, bool includePoints) {
			base.OnPieceCleared(piece, includePoints);

			foreach (var obstacleType in obstacleTypes) {
				if (obstacleType != piece.Type) continue;

				_numObstaclesLeft--;
				hud.SetTarget(_numObstaclesLeft);
				if (_numObstaclesLeft != 0) continue;

				currentScore += ScorePerPieceCleared * (numMoves - _movesUsed);
				hud.SetScore(currentScore);
				GameWin();
			}
		}
	}
}