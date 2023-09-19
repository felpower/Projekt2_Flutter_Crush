using System;
using UnityEngine;

namespace Match3.FlutterUnityIntegration {
	public abstract class SingletonMonoBehaviour<T> : MonoBehaviour where T : MonoBehaviour {
		private static readonly Lazy<T> LazyInstance = new(CreateSingleton);

		public static T Instance => LazyInstance.Value;

		private static T CreateSingleton() {
			var ownerObject = new GameObject($"{typeof(T).Name} (singleton)");
			var instance = ownerObject.AddComponent<T>();
			DontDestroyOnLoad(ownerObject);
			return instance;
		}
	}
}