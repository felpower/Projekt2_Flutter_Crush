using System;
using System.Linq;

namespace Match3 {
	public class LevelColors : Level {
		private const int ScorePerPieceCleared = 50;

		public int numMoves;
		public ColorType[] obstacleTypes;
		public int numOfObstacles;
		private int _movesUsed;
		private int _numObstaclesLeft;

		private void Start() {
			var sceneInfo = SceneInfoExtensions.GetAsSceneInfo();
			if (!string.IsNullOrEmpty(sceneInfo.level)) {
				Setup(sceneInfo);
				numMoves = sceneInfo.numMoves;
				numOfObstacles = sceneInfo.numOfObstacles;
				obstacleTypes = sceneInfo.obstacleTypes.Where(c => Enum.IsDefined(typeof(ColorType), c))
					.Select(c => (ColorType)Enum.Parse(typeof(ColorType), c))
					.ToArray();
			}

			type = LevelType.Colors;
			_numObstaclesLeft = numOfObstacles;
			var obstacles = "";
			foreach (var obstacle in obstacleTypes)
				switch (obstacle) {
					case ColorType.Red:
						obstacles += "Rot, ";
						break;
					case ColorType.Blue:
						obstacles += "Blau, ";
						break;
					case ColorType.Green:
						obstacles += "Grün, ";
						break;
					case ColorType.Yellow:
						obstacles += "Gelb, ";
						break;
					case ColorType.Purple:
						obstacles += "Lila, ";
						break;
					case ColorType.Pink:
						obstacles += "Pink, ";
						break;
				}

			obstacles = obstacles.Substring(0, obstacles.Length - 2);

			hud.SetLevelType(type, obstacles);
			hud.SetScore(currentScore);
			hud.SetTarget(_numObstaclesLeft);
			hud.SetRemaining(numMoves);
		}

		public override void OnMove() {
			_movesUsed++;

			hud.SetRemaining(numMoves - _movesUsed);
			if (numMoves - _movesUsed <= 0) {
				if (_numObstaclesLeft > 0 || currentScore < score1Star) {
					GameLose();
				} else {
					GameWin();
				}
			}
		}

		public override void OnPieceCleared(GamePiece piece, bool includePoints) {
			base.OnPieceCleared(piece, includePoints);

			foreach (var obstacleType in obstacleTypes) {
				if (obstacleType != piece.ColorComponent.Color) continue;

				if (_numObstaclesLeft > 0)
					_numObstaclesLeft--;
				hud.SetTarget(_numObstaclesLeft);
				if (_numObstaclesLeft > 0) continue;

				currentScore += ScorePerPieceCleared * (numMoves - _movesUsed);
				hud.SetScore(currentScore);
				// Check if the current score is greater than or equal to score1Star
				if (currentScore >= score3Star) {
					GameWin();
				}
			}
		}
	}
}