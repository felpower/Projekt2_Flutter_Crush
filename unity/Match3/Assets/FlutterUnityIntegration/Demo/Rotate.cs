using System.Globalization;
using FlutterUnityIntegration;
using UnityEngine;
using UnityEngine.EventSystems;

public class Rotate : MonoBehaviour, IEventSystemHandler
{
    [SerializeField] private Vector3 RotateAmount;

    // Start is called before the first frame update
    private void Start()
    {
        RotateAmount = new Vector3(0, 0, 0);
    }

    // Update is called once per frame
    private void Update()
    {
        gameObject.transform.Rotate(RotateAmount * Time.deltaTime * 120);

        for (var i = 0; i < Input.touchCount; ++i)
            if (Input.GetTouch(i).phase.Equals(TouchPhase.Began))
            {
                var hit = new RaycastHit();

                var ray = Camera.main.ScreenPointToRay(Input.GetTouch(i).position);

                if (Physics.Raycast(ray, out hit))
                    // This method is used to send data to Flutter
                    UnityMessageManager.Instance.SendMessageToFlutter("The cube feels touched.");
            }
    }

    // This method is called from Flutter
    public void SetRotationSpeed(string message)
    {
        var value = float.Parse(message, CultureInfo.InvariantCulture.NumberFormat);
        RotateAmount = new Vector3(value, value, value);
    }
}