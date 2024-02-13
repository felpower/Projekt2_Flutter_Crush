using UnityEngine;

namespace Match3 {
	public class LevelTimer : Level {
		public int timeInSeconds;
		public int targetScore;

		private float _timer;

		private void Start() {
			type = LevelType.Timer;

			hud.SetLevelType(type);
			hud.SetScore(currentScore);
			var sceneInfo = SceneInfoExtensions.GetAsSceneInfo();
			if (!string.IsNullOrEmpty(sceneInfo.level)) {
				Setup(sceneInfo);
				targetScore = sceneInfo.targetScore;
				timeInSeconds = sceneInfo.timeInSeconds;
			}

			hud.SetTarget(score1Star);
			hud.SetRemaining($"{timeInSeconds / 60}:{timeInSeconds % 60:00}");
		}

		private void Update() {
			_timer += Time.deltaTime;
			hud.SetRemaining(
				$"{(int)Mathf.Max((timeInSeconds - _timer) / 60, 0)}:{(int)Mathf.Max((timeInSeconds - _timer) % 60, 0):00}");

			if (timeInSeconds - _timer <= 0 || currentScore >= targetScore) {
				if (currentScore >= score1Star)
					GameWin();
				else
					GameLose();
			}
		}
	}
}