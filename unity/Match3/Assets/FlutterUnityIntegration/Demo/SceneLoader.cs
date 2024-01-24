using UnityEngine;
using UnityEngine.SceneManagement;

namespace Match3.FlutterUnityIntegration.Demo {
	public class SceneLoader : MonoBehaviour {
		public void LoadScene(int idx) {
			Debug.Log("scene = " + idx);
			SceneManager.LoadScene(idx, LoadSceneMode.Single);
		}

		public void MessengerFlutter() { UnityMessageManager.Instance.SendMessageToFlutter("Hey man"); }

		public void SwitchNative() { UnityMessageManager.Instance.ShowHostMainWindow(); }

		public void UnloadNative() { UnityMessageManager.Instance.UnloadMainWindow(); }

		public void QuitNative() { UnityMessageManager.Instance.QuitUnityWindow(); }
	}
}