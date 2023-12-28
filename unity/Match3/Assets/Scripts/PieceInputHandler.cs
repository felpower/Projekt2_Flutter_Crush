namespace Match3 {
	using UnityEngine;

	public class PieceInputHandler : MonoBehaviour
	{
		private Vector2 _startDragPosition;
		private Vector2 _currentDragPosition;
		private GameGrid _gameGrid;
		private GamePiece _thisPiece;
		
		private void Awake()
		{
			_gameGrid = FindObjectOfType<GameGrid>();
			_thisPiece = GetComponent<GamePiece>();
		}

		private void OnMouseDown()
		{
			print("Mouse down");
			_startDragPosition = Input.mousePosition;
			_gameGrid.PressPiece(_thisPiece);
		}

		private void OnMouseDrag()
		{
			print("Dragging");
			_currentDragPosition = Input.mousePosition;
			var dragVector = _currentDragPosition - _startDragPosition;

			// Invert the y component of the drag vector
			dragVector.y = -dragVector.y;

			// Calculate direction. Normalize to get direction vector
			var direction = dragVector.normalized;

			// Round to nearest integer to get offsets to adjacent piece
			var xDirection = Mathf.RoundToInt(direction.x);
			var yDirection = Mathf.RoundToInt(direction.y);

			// Ensure that direction is within the bounds of the game grid
			var targetX = Mathf.Clamp(_thisPiece.X + xDirection, 0, _gameGrid.xDim - 1);
			var targetY = Mathf.Clamp(_thisPiece.Y + yDirection, 0, _gameGrid.yDim - 1);

			// Get the adjacent piece in the direction of the drag
			var adjacentPiece = _gameGrid.GetPieceAt(targetX, targetY);

			// Call EnterPiece with the adjacent piece
			_gameGrid.EnterPiece(adjacentPiece);
		}

		private void OnMouseUp()
		{
			print("Mouse up");
			_gameGrid.ReleasePiece();
		}
	}
}