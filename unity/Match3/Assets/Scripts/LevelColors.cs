using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Match3
{
    public class LevelColors : Level
    {

        public int numMoves;
        public ColorType[] obstacleTypes;
        public int numOfObstacles;
        private const int ScorePerPieceCleared = 1000;
        public ColorType color;
        private int _movesUsed = 0;
        private int _numObstaclesLeft;

        private void Start ()
        {
            type = LevelType.Colors;
            _numObstaclesLeft = numOfObstacles;
            hud.SetLevelType(type, color);
            hud.SetScore(currentScore);
            hud.SetTarget(_numObstaclesLeft);
            hud.SetRemaining(numMoves);
        }

        public override void OnMove()
        {
            _movesUsed++;

            hud.SetRemaining(numMoves - _movesUsed);

            if (numMoves - _movesUsed == 0 && _numObstaclesLeft > 0)
            {
                GameLose();
            }
        }

        public override void OnPieceCleared(GamePiece piece, bool includePoints)
        {
            base.OnPieceCleared(piece, includePoints);

            for (int i = 0; i < obstacleTypes.Length; i++)
            {
                if (obstacleTypes[i] != piece.ColorComponent.Color) continue;
                
                if(_numObstaclesLeft > 0)
                    _numObstaclesLeft--;
                hud.SetTarget(_numObstaclesLeft);
                if (_numObstaclesLeft > 0) continue;
            
                currentScore += ScorePerPieceCleared * (numMoves - _movesUsed);
                hud.SetScore(currentScore);
                GameWin();
            }
        }
    }
}
