using UnityEngine;
namespace Match3
{
    public class LevelMoves : Level
    {

        public int numMoves;
        public int targetScore;

        private int _movesUsed;

        private void Start()
        {
            type = LevelType.Moves;
            hud.SetLevelType(type);
            hud.SetScore(currentScore);
            var sceneInfo = SceneInfoExtensions.GetAsSceneInfo();
            if (!string.IsNullOrEmpty(sceneInfo.level)) {
                Setup(sceneInfo);
                numMoves = sceneInfo.numMoves;
                targetScore = sceneInfo.targetScore;
            }
            hud.SetTarget(targetScore);
            hud.SetRemaining(numMoves);
        }

        public override void OnMove()
        {
            _movesUsed++;

            hud.SetRemaining(numMoves - _movesUsed);

            if (numMoves - _movesUsed != 0) return;

            if (currentScore >= targetScore) {
                GameWin();
            } else {
                GameLose();
            }
        }
    }
}
