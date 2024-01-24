using Newtonsoft.Json;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Match3.FlutterUnityIntegration.Demo {
	public class GameManager : MonoBehaviour {
		public static bool isMusicOn = true;
		public GameGrid gameGrid;

		private void Start() {
			gameObject.AddComponent<UnityMessageManager>();
			gameGrid = FindObjectOfType<GameGrid>();
		}

		public void LoadScene(string json) {
			var sceneInfo = SceneInfo.CreateFromJson(json);
			if (sceneInfo.level is null) UnityMessageManager.Instance.SendMessageToFlutter("Resend Level Info");
			SceneInfoExtensions.StaticSave(sceneInfo);
			UnityMessageManager.Instance.SendMessageToFlutter("Static Scene Info Game Manager: " +
			                                                  JsonConvert.SerializeObject(
				                                                  SceneInfoExtensions.GetAsSceneInfo()));
			SceneManager.LoadScene(sceneInfo.type + sceneInfo.orientation);
		}

		public void CheckReady(string checkReady) {
			print("CheckReady: " + checkReady);
			UnityMessageManager.Instance.SendMessageToFlutter("checkReady");
		}


		public void Music(string music) {
			print("Music: " + music);
			isMusicOn = music.ToLower() == "true";
			if (isMusicOn) {
				gameGrid.audioSource.Play(); // Access the AudioSource from the GameGrid script
			} else {
				gameGrid.audioSource.Stop(); // Access the AudioSource from the GameGrid script
			}
		}

		private void HandleWebFnCall(string action) {
			switch (action) {
				case "pause":
					Time.timeScale = 0;
					break;
				case "resume":
					Time.timeScale = 1;
					break;
				case "unload":
					Application.Unload();
					break;
				case "quit":
					Application.Quit();
					break;
			}
		}
	}
}