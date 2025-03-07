﻿using Newtonsoft.Json;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Match3.FlutterUnityIntegration.Demo {
	public class GameManager : MonoBehaviour {
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