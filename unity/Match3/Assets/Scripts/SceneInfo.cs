using System;
using UnityEngine;

namespace Match3 {
	[Serializable]
	public class SceneInfo {
		public string level;
		public string type;
		public string orientation;
		public string levelName;
		public int xDim;
		public int yDim;
		public int numMoves;
		public int score1;
		public int score2;
		public int score3;
		public int targetScore;
		public int timeInSeconds;
		public int numOfObstacles;
		public string[] obstacleTypes;

		public SceneInfo(string level, string type, string orientation, string levelName, int xDim, int yDim,
			int numMoves, int score1, int score2, int score3, int targetScore, int timeInSeconds, int numOfObstacles,
			string[] obstacleTypes) {
			this.level = level;
			this.type = type;
			this.orientation = orientation;
			this.levelName = levelName;
			this.xDim = xDim;
			this.yDim = yDim;
			this.numMoves = numMoves;
			this.score1 = score1;
			this.score2 = score2;
			this.score3 = score3;
			this.targetScore = targetScore;
			this.timeInSeconds = timeInSeconds;
			this.numOfObstacles = numOfObstacles;
			this.obstacleTypes = obstacleTypes;
		}

		public static SceneInfo CreateFromJson(string jsonString) {
			return JsonUtility.FromJson<SceneInfo>(jsonString);
		}
	}

	public static class SceneInfoExtensions {
		private static string level;
		private static string type;
		private static string orientation;
		private static string levelName;
		private static int xDim;
		private static int yDim;
		private static int numMoves;
		private static int score1;
		private static int score2;
		private static int score3;
		private static int targetScore;
		private static int timeInSeconds;
		private static int numOfObstacles;
		private static string[] obstacleTypes;

		public static SceneInfo GetAsSceneInfo() {
			return new SceneInfo(level, type, orientation, levelName, xDim, yDim, numMoves, score1, score2, score3,
				targetScore, timeInSeconds, numOfObstacles, obstacleTypes);
		}

		public static void StaticSave(SceneInfo sceneInfo) {
			level = sceneInfo.level;
			type = sceneInfo.type;
			orientation = sceneInfo.orientation;
			levelName = type + orientation;
			xDim = sceneInfo.xDim;
			yDim = sceneInfo.yDim;
			numMoves = sceneInfo.numMoves;
			score1 = sceneInfo.score1;
			score2 = sceneInfo.score2;
			score3 = sceneInfo.score3;
			targetScore = sceneInfo.targetScore;
			timeInSeconds = sceneInfo.timeInSeconds;
			numOfObstacles = sceneInfo.numOfObstacles;
			obstacleTypes = sceneInfo.obstacleTypes;
		}
	}
}