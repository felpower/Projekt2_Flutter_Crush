using System.Collections;
using FlutterUnityIntegration;
using Newtonsoft.Json;
using UnityEngine;
namespace Match3
{
    public class Level : MonoBehaviour
    {
        public GameGrid gameGrid;
        public Hud hud;

        public int score1Star;
        public int score2Star;
        public int score3Star;

        private bool _didWin;

        protected int currentScore;

        protected LevelType type;

        public LevelType Type => type;

        private void Start()
        {
            
        }

        protected void Setup(SceneInfo sceneInfo)
        {
            gameObject.AddComponent<UnityMessageManager>();
            
            UnityMessageManager.Instance.SendMessageToFlutter("Static Scene Info Level: " + JsonConvert.SerializeObject(sceneInfo));
            if (!string.IsNullOrEmpty(sceneInfo.level)) {
                score1Star = sceneInfo.score1;
                score2Star = sceneInfo.score2;
                score3Star = sceneInfo.score3;
                gameGrid.xDim = sceneInfo.xDim;
                gameGrid.yDim = sceneInfo.yDim;
            }
        }

        protected virtual void GameWin()
        {
            gameGrid.GameOver();
            _didWin = true;
            StartCoroutine(WaitForGridFill());
        }

        protected virtual void GameLose()
        {
            gameGrid.GameOver();
            _didWin = false;
            StartCoroutine(WaitForGridFill());
        }

        public virtual void OnMove()
        {
        }

        public virtual void OnPieceCleared(GamePiece piece, bool includePoints)
        {
            if (includePoints) {
                currentScore += piece.score;
                hud.SetScore(currentScore);
            }
        }

        protected virtual IEnumerator WaitForGridFill()
        {
            while (gameGrid.IsFilling) {
                yield return null;
            }

            if (_didWin) {
                hud.OnGameWin(currentScore);
            } else {
                hud.OnGameLose();
            }
        }
    }
}
