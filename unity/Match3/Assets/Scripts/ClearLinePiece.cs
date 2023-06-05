namespace Match3
{
    internal class ClearLinePiece : ClearablePiece
    {
        public bool isRow;

        public override void Clear(bool includePoints)
        {
            base.Clear(includePoints);

            if (isRow) {
                piece.GameGridRef.ClearRow(piece.Y);
            } else {
                piece.GameGridRef.ClearColumn(piece.X);
            }
        }
    }
}
