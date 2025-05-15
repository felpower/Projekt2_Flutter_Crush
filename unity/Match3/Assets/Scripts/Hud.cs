using Match3.FlutterUnityIntegration;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace Match3
{
	public class Hud : MonoBehaviour
	{
		public Level level;
		public GameOver gameOver;

		public CanvasScaler canvasScaler; // Reference to the CanvasScaler

		public Text remainingText;
		public Text remainingSubText;
		public Text targetText;
		public Text targetSubtext;
		public Text scoreText;
		public Image[] stars;
		private bool _changed;

		private int _starIndex;

		private void Start()
		{
			gameObject.AddComponent<UnityMessageManager>();
			NotifyGameUICanvasReady();
			for (var i = 0; i < stars.Length; i++) stars[i].enabled = i == _starIndex;
		}

		public void NotifyGameUICanvasReady()
		{
			UnityMessageManager.Instance.SendMessageToFlutter("GameUICanvasReady");
		}


		public void OnScalingSliderChanged(string value)
		{
			// Try to parse the string value to a float
			if (float.TryParse(value, out float scaleFactor))
			{
				// Adjust the CanvasScaler's scale factor based on the parsed float value
				if (canvasScaler != null)
				{
					canvasScaler.scaleFactor = scaleFactor;
				}
			}
			else
			{
				Debug.LogWarning("Invalid float value: " + value);
			}
		}

		public void SetScore(int score)
		{
			scoreText.text = score.ToString();

			var visibleStar = 0;

			if (score >= level.score1Star && score < level.score2Star)
			{
				visibleStar = 1;
				_changed = true;
			}
			else if (score >= level.score2Star && score < level.score3Star)
			{
				visibleStar = 2;
				_changed = true;
			}
			else if (score >= level.score3Star)
			{
				visibleStar = 3;
				_changed = true;
			}

			if (_changed)
			{
				if (level.isFlutter)
					UnityMessageManager.Instance.SendMessageToFlutter("Reached Star: " + visibleStar);
				_changed = false;
			}

			for (var i = 0; i < stars.Length; i++) stars[i].enabled = i == visibleStar;

			_starIndex = visibleStar;
		}

		public void SetTarget(int target) { targetText.text = target.ToString(); }

		public void SetRemaining(int remaining) { remainingText.text = remaining.ToString(); }

		public void SetRemaining(string remaining) { remainingText.text = remaining; }

		public void SetLevelType(LevelType type, string colorType = "Any")
		{
			switch (type)
			{
				case LevelType.Moves:
					remainingSubText.text = "Verbleibende Züge";
					targetSubtext.text = "Zielpunktzahl";
					break;
				case LevelType.Obstacle:
					remainingSubText.text = "Verbleibende Züge";
					targetSubtext.text = "Verbleibende Blasen";
					break;
				case LevelType.Timer:
					remainingSubText.text = "Verbleibende Zeit";
					targetSubtext.text = "Zielpunktzahl";
					break;
				case LevelType.Colors:
					remainingSubText.text = "Verbleibende Züge";
					targetSubtext.text = colorType + " verbleibend";
					break;
			}
		}

		public void OnGameWin(int score)
		{
			gameOver.ShowWin(score, _starIndex, level.isFlutter);
			if (_starIndex > PlayerPrefs.GetInt(SceneManager.GetActiveScene().name, 0))
				PlayerPrefs.SetInt(SceneManager.GetActiveScene().name, _starIndex);
		}

		public void OnGameLose() { gameOver.ShowLose(level.isFlutter); }
	}
}