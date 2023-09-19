using System;
using System.Collections.Generic;
using FlutterUnityIntegration;
using Newtonsoft.Json.Linq;
using UnityEngine.SceneManagement;

namespace Match3.FlutterUnityIntegration {
	public class MessageHandler {
		private readonly JToken data;
		public int id;

		public string name;
		public string seq;

		public MessageHandler(int id, string seq, string name, JToken data) {
			this.id = id;
			this.seq = seq;
			this.name = name;
			this.data = data;
		}

		public static MessageHandler Deserialize(string message) {
			var m = JObject.Parse(message);
			var handler = new MessageHandler(
				m.GetValue("id").Value<int>(),
				m.GetValue("seq").Value<string>(),
				m.GetValue("name").Value<string>(),
				m.GetValue("data")
			);
			return handler;
		}

		public T getData<T>() { return data.Value<T>(); }

		public void send(object data) {
			var o = JObject.FromObject(new {
				id,
				seq = "end",
				name,
				data
			});
			UnityMessageManager.Instance.SendMessageToFlutter(UnityMessageManager.MessagePrefix + o);
		}
	}

	public class UnityMessage {
		public Action<object> callBack;
		public JObject data;
		public string name;
	}

	public class UnityMessageManager : SingletonMonoBehaviour<UnityMessageManager> {
		public delegate void MessageDelegate(string message);

		public delegate void MessageHandlerDelegate(MessageHandler handler);

		public const string MessagePrefix = "@UnityMessage@";
		private static int ID;

		private readonly Dictionary<int, UnityMessage> waitCallbackMessageMap = new();

		private void Start() { SceneManager.sceneLoaded += OnSceneLoaded; }

		private static int generateId() {
			ID = ID + 1;
			return ID;
		}

		public event MessageDelegate OnMessage;
		public event MessageHandlerDelegate OnFlutterMessage;

		private void OnSceneLoaded(Scene scene, LoadSceneMode mode) { NativeAPI.OnSceneLoaded(scene, mode); }

		public void ShowHostMainWindow() { NativeAPI.ShowHostMainWindow(); }

		public void UnloadMainWindow() { NativeAPI.UnloadMainWindow(); }


		public void QuitUnityWindow() { NativeAPI.QuitUnityWindow(); }


		public void SendMessageToFlutter(string message) { NativeAPI.SendMessageToFlutter(message); }

		public void SendMessageToFlutter(UnityMessage message) {
			var id = generateId();
			if (message.callBack != null) waitCallbackMessageMap.Add(id, message);

			var o = JObject.FromObject(new {
				id,
				seq = message.callBack != null ? "start" : "",
				message.name,
				message.data
			});
			Instance.SendMessageToFlutter(MessagePrefix + o);
		}

		private void onMessage(string message) { OnMessage?.Invoke(message); }

		private void onFlutterMessage(string message) {
			if (message.StartsWith(MessagePrefix))
				message = message.Replace(MessagePrefix, "");
			else
				return;

			var handler = MessageHandler.Deserialize(message);
			if ("end".Equals(handler.seq)) {
				// handle callback message
				if (!waitCallbackMessageMap.TryGetValue(handler.id, out var m)) return;
				waitCallbackMessageMap.Remove(handler.id);
				m.callBack?.Invoke(handler.getData<object>()); // todo
				return;
			}

			OnFlutterMessage?.Invoke(handler);
		}
	}
}