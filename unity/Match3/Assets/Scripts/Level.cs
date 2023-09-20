using System;
using System.Collections;
using FlutterUnityIntegration;
using Match3.FlutterUnityIntegration;
using Newtonsoft.Json;
using UnityEngine;
using UnityEngine.Serialization;

namespace Match3 {
	public class Level : MonoBehaviour {
		public GameGrid gameGrid;
		public Hud hud;

		public int score1Star;
		public int score2Star;
		public int score3Star;

		[FormerlySerializedAs("_isFlutter")] public bool isFlutter;

		private bool _didWin;

		protected int currentScore;

		protected LevelType type;

		public LevelType Type => type;

		private void Awake() { StartCoroutine(IsFlutter()); }

		private IEnumerator IsFlutter() {
			yield return new WaitForSeconds(1);
			print("Is Flutter? " + isFlutter);
			if (!isFlutter)
				gameGrid.Instantiate();
		}

		protected void Setup(SceneInfo sceneInfo) {
			isFlutter = true;
			print(gameObject.name + " Setup");
			if (!string.IsNullOrEmpty(sceneInfo.level)) {
				gameGrid.xDim = sceneInfo.xDim;
				gameGrid.yDim = sceneInfo.yDim;
				score1Star = sceneInfo.score1;
				score2Star = sceneInfo.score2;
				score3Star = sceneInfo.score3;
				type = Enum.Parse<LevelType>(sceneInfo.type);
			}

			gameGrid.Instantiate();

			gameObject.AddComponent<UnityMessageManager>();
			UnityMessageManager.Instance.SendMessageToFlutter("Static Scene Info Level: " +
			                                                  JsonConvert.SerializeObject(sceneInfo));
		}

		protected void GameWin() {
			gameGrid.GameOver();
			_didWin = true;
			StartCoroutine(WaitForGridFill());
		}

		protected void GameLose() {
			gameGrid.GameOver();
			_didWin = false;
			StartCoroutine(WaitForGridFill());
		}

		public void ShufflePieces() { gameGrid.ClearAll(); }

		public void NoMoreMoves() { UnityMessageManager.Instance.SendMessageToFlutter("Shuffle No more moves"); }

		public virtual void OnMove() { }

		public virtual void OnPieceCleared(GamePiece piece, bool includePoints) {
			if (includePoints) {
				currentScore += piece.score;
				hud.SetScore(currentScore);
			}
		}

		private IEnumerator WaitForGridFill() {
			while (gameGrid.IsFilling) yield return null;

			if (_didWin)
				hud.OnGameWin(currentScore);
			else
				hud.OnGameLose();
		}

		public virtual void SetNumOfObstacles() { throw new NotImplementedException(); }
	}
}