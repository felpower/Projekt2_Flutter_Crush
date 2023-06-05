using System;
using UnityEngine;
namespace Match3
{
    public class LevelSelect : MonoBehaviour
    {

        public ButtonPlayerPrefs[] buttons;


        public GameObject Empty;

        private void Start()
        {
            for (int i = 0; i < buttons.Length; i++) {
                int score = PlayerPrefs.GetInt(buttons[i].playerPrefKey, 0);

                for (int starIndex = 1; starIndex <= 3; starIndex++) {
                    Transform star = buttons[i].gameObject.transform.Find($"star{starIndex}");
                    star.gameObject.SetActive(starIndex <= score);
                }
            }
        }

        public void OnButtonPress(string levelName)
        {
            GameLoader.instance.LoadScene(levelName);
        }
        [Serializable]
        public struct ButtonPlayerPrefs
        {
            public GameObject gameObject;
            public string playerPrefKey;
        }
    }
}
