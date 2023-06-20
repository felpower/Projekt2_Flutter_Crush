using UnityEngine;
namespace Match3
{
    [System.Serializable]
    public class SceneInfo
    {
        public string level;
        public int xDim;
        public int yDim;
        public int numMoves;
        public int score1;
        public int score2;
        public int score3;
        public int targetScore;
        public int timeInSeconds;
        public int numOfObstacles;

        public static SceneInfo CreateFromJson(string jsonString)
        {
            return JsonUtility.FromJson<SceneInfo>(jsonString);
        }

        public override string ToString() => "level: " + level + ", xDim: " + xDim + ", yDim: " + yDim + ", numMoves: " + numMoves + ", score1: " + score1 + ", score2: " + score2 + ", score3: " + score3 + ", targetScore: " +
                                             targetScore + ", timeInSeconds: " + timeInSeconds + ", numOfObstacles: " + numOfObstacles;
    }

    public static class SceneInfoExtensions
    {
        private static string level;
        private static int xDim;
        private static int yDim;
        private static int numMoves;
        private static int score1;
        private static int score2;
        private static int score3;
        private static int targetScore;
        private static int timeInSeconds;
        private static int numOfObstacles;

        public static string toString()
        {
            return "level: " + level + ", xDim: " + xDim + ", yDim: " + yDim + ", numMoves: " + numMoves + ", score1: " + score1 + ", score2: " + score2 + ", score3: " + score3 + ", targetScore: " +
                   targetScore + ", timeInSeconds: " + timeInSeconds + ", numOfObstacles: " + numOfObstacles;
        }

        public static void StaticSave(SceneInfo sceneInfo)
        {
            level = sceneInfo.level;
            xDim = sceneInfo.xDim;
            yDim = sceneInfo.yDim;
            numMoves = sceneInfo.numMoves;
            score1 = sceneInfo.score1;
            score2 = sceneInfo.score2;
            score3 = sceneInfo.score3;
            targetScore = sceneInfo.targetScore;
            timeInSeconds = sceneInfo.timeInSeconds;
            numOfObstacles = sceneInfo.numOfObstacles;
        }

        public static string ToJson()
        {
            return "{\"level\": \"" + level + "\", \"xDim\": \" " + xDim + "\", \"yDim\": \" " + yDim + "\", \"numMoves\": \" " + numMoves + "\", \"score1\": \" " + score1 + "\", \"score2\": \" " + score2 + "\", \"score3\": \" " + score3 + "\", \"targetScore\": \" " +
                   targetScore + "\", \"timeInSeconds\": \" " + timeInSeconds + "\", \"numOfObstacles\": \" " + numOfObstacles+"\"}";
        }
    }
}
