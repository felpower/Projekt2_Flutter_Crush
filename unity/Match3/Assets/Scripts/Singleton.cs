using UnityEngine;
using UnityEngine.SceneManagement;

public class GameLoader : MonoBehaviour
{
    public static GameLoader instance { get; private set; }
    private void Awake()
    {
        if (instance == null)
            instance = this;
    }

    public void LoadScene(string levelName)
    {
        SceneManager.LoadScene(levelName, LoadSceneMode.Single);
    }
}