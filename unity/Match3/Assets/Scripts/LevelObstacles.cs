namespace Match3 {
	public class LevelObstacles : Level {
		private const int ScorePerPieceCleared = 50;

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


			hud.SetLevelType(type);
			hud.SetScore(currentScore);
			hud.SetRemaining(numMoves);
		}

		public override void OnMove() {
			_movesUsed++;

			hud.SetRemaining(numMoves - _movesUsed);

			if (numMoves - _movesUsed <= 0) {
				if (_numObstaclesLeft > 0 || currentScore < score1Star) {
					GameLose();
				} else if (currentScore >= score1Star) {
					GameWin();
				}
			}
		}

		public override void SetNumOfObstacles() {
			foreach (var obstacleType in obstacleTypes)
				_numObstaclesLeft += gameGrid.GetPiecesOfType(obstacleType).Count;
			hud.SetTarget(_numObstaclesLeft);
		}

		public override void OnPieceCleared(GamePiece piece, bool includePoints) {
			base.OnPieceCleared(piece, includePoints);

			foreach (var obstacleType in obstacleTypes) {
				if (obstacleType != piece.Type) continue;

				_numObstaclesLeft--;
				hud.SetTarget(_numObstaclesLeft);
				if (_numObstaclesLeft > 0) continue;

				currentScore += ScorePerPieceCleared * (numMoves - _movesUsed);
				hud.SetScore(currentScore);

				if (currentScore >= score3Star) { 
					GameWin();
				}
			}
		}
	}
}