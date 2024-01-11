using UnityEngine;

namespace Match3 {
	public class GamePiece : MonoBehaviour {
		public int score;

		private int _x;
		private int _y;

		public int X {
			get => _x;
			set {
				if (IsMovable()) _x = value;
			}
		}

		public int Y {
			get => _y;
			set {
				if (IsMovable()) _y = value;
			}
		}

		public PieceType Type { get; private set; }

		public GameGrid GameGridRef { get; private set; }

		public MovablePiece MovableComponent { get; private set; }


		public ColorPiece ColorComponent { get; private set; }

		public ClearablePiece ClearableComponent { get; private set; }

		private void Awake() {
			MovableComponent = GetComponent<MovablePiece>();
			ColorComponent = GetComponent<ColorPiece>();
			ClearableComponent = GetComponent<ClearablePiece>();
		}

		public void Init(int x, int y, GameGrid gameGrid, PieceType type) {
			_x = x;
			_y = y;
			GameGridRef = gameGrid;
			Type = type;
			// Attach the PieceInputHandler script
			gameObject.AddComponent<PieceInputHandler>();
		}


		public bool IsMovable() { return MovableComponent != null; }

		public bool IsColored() { return ColorComponent != null; }

		public bool IsSameColor(GamePiece gamePiece) {
			if (gamePiece.ColorComponent == null || ColorComponent == null)
				return false;
			return ColorComponent.Color.Equals(gamePiece.ColorComponent.Color);
		}

		public bool IsClearable() { return ClearableComponent != null; }
	}
}