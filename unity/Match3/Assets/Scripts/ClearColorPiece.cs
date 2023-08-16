namespace Match3
{
    public class ClearColorPiece : ClearablePiece
    {
        public ColorType Color { get; set; }

        public override void Clear(bool includePoints)
        {
            base.Clear(includePoints);

            piece.GameGridRef.ClearColor(Color);
        }
    }
}