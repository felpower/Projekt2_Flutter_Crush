using Newtonsoft.Json;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Match3.FlutterUnityIntegration.Demo {
	public class GameManager : MonoBehaviour {
		public static bool isMusicOn;
		private void Start() { gameObject.AddComponent<UnityMessageManager>(); }

		public void LoadScene(string json) {
			var sceneInfo = SceneInfo.CreateFromJson(json);
			if (sceneInfo.level is null) UnityMessageManager.Instance.SendMessageToFlutter("Resend Level Info");
			SceneInfoExtensions.StaticSave(sceneInfo);
			UnityMessageManager.Instance.SendMessageToFlutter("Static Scene Info Game Manager: " +
			                                                  JsonConvert.SerializeObject(
				                                                  SceneInfoExtensions.GetAsSceneInfo()));
			SceneManager.LoadScene(sceneInfo.type + sceneInfo.orientation);
		}

		public void CheckReady(string checkReady) { UnityMessageManager.Instance.SendMessageToFlutter("checkReady"); }


		public void Music(string music) {
			print("Music: " + music);
			isMusicOn = music.ToLower() == "true";
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