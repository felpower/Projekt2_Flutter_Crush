using FlutterUnityIntegration;
using Match3;
using Newtonsoft.Json;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    // Start is called before the first frame update
    private void Start()
    {
        gameObject.AddComponent<UnityMessageManager>();
    }

    // Update is called once per frame
    private void Update()
    {
    }

    public void LoadScene(string json)
    {
        var sceneInfo = SceneInfo.CreateFromJson(json);
        if (sceneInfo.level is null) UnityMessageManager.Instance.SendMessageToFlutter("Resend Level Info");
        SceneInfoExtensions.StaticSave(sceneInfo);
        UnityMessageManager.Instance.SendMessageToFlutter("Static Scene Info Game Manager: " +
                                                          JsonConvert.SerializeObject(
                                                              SceneInfoExtensions.GetAsSceneInfo()));
        SceneManager.LoadScene(sceneInfo.type + sceneInfo.orientation);
    }

    public void LoadStartScene(string startScreen)
    {
        SceneManager.LoadScene(startScreen);
    }
    
    public void CheckReady(string checkReady)
    {
        Debug.Log(checkReady);
        UnityMessageManager.Instance.SendMessageToFlutter("checkReady");
    }

    private void HandleWebFnCall(string action)
    {
        switch (action)
        {
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