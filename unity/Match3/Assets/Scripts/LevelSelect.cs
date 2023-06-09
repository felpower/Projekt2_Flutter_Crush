using System;
using FlutterUnityIntegration;
using UnityEngine;
namespace Match3
{
    public class LevelSelect : MonoBehaviour
    {

        public ButtonPlayerPrefs[] buttons;


        public GameObject Empty;

        private void Start()
        {
            gameObject.AddComponent<UnityMessageManager>();
            for (int i = 0; i < buttons.Length; i++) {
                int score = PlayerPrefs.GetInt(buttons[i].playerPrefKey, 0);

                for (int starIndex = 1; starIndex <= 3; starIndex++) {
                    Transform star = buttons[i].gameObject.transform.Find($"star{starIndex}");
                    star.gameObject.SetActive(starIndex <= score);
                }
            }
        }

        public void OnButtonPress(string level)
        {
            UnityMessageManager.Instance.SendMessageToFlutter("Scene Loaded");
            GameLoader.instance.LoadScene(level);
           
        }
        [Serializable]
        public struct ButtonPlayerPrefs
        {
            public GameObject gameObject;
            public string playerPrefKey;
        }
    }
}
