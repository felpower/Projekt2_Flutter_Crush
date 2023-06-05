using FlutterUnityIntegration;
using UnityEngine;
public class GameManager : MonoBehaviour
{
    // Start is called before the first frame update
    // Start is called before the first frame update
    private void Start()
    {
        gameObject.AddComponent<UnityMessageManager>();
    }

    // Update is called once per frame
    private void Update()
    {
    }

    private void HandleWebFnCall(string action)
    {
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
