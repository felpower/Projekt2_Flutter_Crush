using Match3.FlutterUnityIntegration;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Match3 {
	public class GameLoader : MonoBehaviour {
		public static GameLoader Instance { get; private set; }

		private void Awake() {
			gameObject.AddComponent<UnityMessageManager>();
			if (Instance == null)
				Instance = this;
		}

		public void LoadScene(string levelName) {
			SceneManager.LoadScene(levelName);
			UnityMessageManager.Instance.SendMessageToFlutter("Scene Loaded");
		}
	}
}