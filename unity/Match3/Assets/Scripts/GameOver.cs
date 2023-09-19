using System.Collections;
using FlutterUnityIntegration;
using Match3.FlutterUnityIntegration;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace Match3 {
	public class GameOver : MonoBehaviour {
		public GameObject screenParent;
		public GameObject scoreParent;
		public Text loseText;
		public Text scoreText;
		public Image[] stars;

		private void Start() {
			screenParent.SetActive(false);

			foreach (var star in stars)
				star.enabled = false;
		}

		public void ShowLose(bool levelIsFlutter) {
			screenParent.SetActive(true);
			scoreParent.SetActive(false);
			if (levelIsFlutter)
				UnityMessageManager.Instance.SendMessageToFlutter("GameOver: Lost");
		}

		public void ShowWin(int score, int starCount, bool levelIsFlutter) {
			screenParent.SetActive(true);
			loseText.enabled = false;

			scoreText.text = score.ToString();
			scoreText.enabled = false;
			if (levelIsFlutter)
				UnityMessageManager.Instance.SendMessageToFlutter("GameOver: Won, StarCount: " + starCount);
			var animator = GetComponent<Animator>();

			if (animator) animator.Play("GameOverShow");

			StartCoroutine(ShowWinCoroutine(starCount));
		}

		private IEnumerator ShowWinCoroutine(int starCount) {
			yield return new WaitForSeconds(0.5f);

			if (starCount < stars.Length)
				for (var i = 0; i <= starCount; i++) {
					stars[i].enabled = true;

					if (i > 0) stars[i - 1].enabled = false;

					yield return new WaitForSeconds(0.5f);
				}

			scoreText.enabled = true;
		}

		public void OnReplayClicked() { SceneManager.LoadScene(SceneManager.GetActiveScene().name); }

		public void OnDoneClicked() { UnityMessageManager.Instance.SendMessageToFlutter("Score: " + scoreText.text); }
	}
}