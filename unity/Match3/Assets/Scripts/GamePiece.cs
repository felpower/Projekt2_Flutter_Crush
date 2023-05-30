using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
namespace Match3 {
    public class GamePiece : MonoBehaviour, IDragHandler, IBeginDragHandler, IEndDragHandler {
        public int score;

        private int _x;
        private int _y;

        public int X {
            get => _x;
            set { if (IsMovable()) { _x = value; } }
        }

        public int Y {
            get => _y;
            set { if (IsMovable()) { _y = value; } }
        }

        private PieceType _type;

        public PieceType Type => _type;

        private GameGrid _gameGrid;

        public GameGrid GameGridRef => _gameGrid;

        private MovablePiece _movableComponent;

        public MovablePiece MovableComponent => _movableComponent;

        private ColorPiece _colorComponent;

        public ColorPiece ColorComponent => _colorComponent;

        private ClearablePiece _clearableComponent;

        public ClearablePiece ClearableComponent => _clearableComponent;

        private Touch theTouch;

        private void Awake() {
            _movableComponent = GetComponent<MovablePiece>();
            _colorComponent = GetComponent<ColorPiece>();
            _clearableComponent = GetComponent<ClearablePiece>();
        }

        public void Update() {
            //if (Input.touchCount > 0) {
            //    theTouch = Input.GetTouch(0);
            //    if (theTouch.phase == TouchPhase.Began) {
            //        _gameGrid.PressPiece(this);
            //    } else if (theTouch.phase == TouchPhase.Moved) {
            //        //Debug.Log(this.X + " " + this.Y);
            //        _gameGrid.EnterPiece(this);
            //    } else if (theTouch.phase == TouchPhase.Ended) {
            //        _gameGrid.ReleasePiece();
            //    }
            //}
        }

        public void Init(int x, int y, GameGrid gameGrid, PieceType type) {
            _x = x;
            _y = y;
            _gameGrid = gameGrid;
            _type = type;
        }

        private void OnMouseEnter() {
            if (SystemInfo.deviceType == DeviceType.Desktop) {
                //Debug.LogWarning("Mouse Entered: " + this.X + " " + this.Y);
                _gameGrid.EnterPiece(this);
            }
        }

        private void OnMouseDown() {
            if (SystemInfo.deviceType == DeviceType.Desktop) {
                //Debug.LogWarning("Mouse Down");
                _gameGrid.PressPiece(this);
            }
        }

        private void OnMouseUp() {
            if (SystemInfo.deviceType == DeviceType.Desktop) {
                //Debug.LogWarning("Mouse Up");
                _gameGrid.ReleasePiece();
            }
        }

        public bool IsMovable() => _movableComponent != null;

        public bool IsColored() => _colorComponent != null;

        public bool IsClearable() => _clearableComponent != null;

        public void OnEndDrag(PointerEventData eventData) {
            if (SystemInfo.deviceType == DeviceType.Handheld) {
                //Debug.LogWarning("Drag End");
                _gameGrid.ReleasePiece();
            }
        }
        public void OnDrag(PointerEventData eventData) {
            if (SystemInfo.deviceType == DeviceType.Handheld) {
                //Debug.LogWarning("Drag");
                _gameGrid.EnterPiece(this);
            }
        }

        public void OnBeginDrag(PointerEventData eventData) {
            if (SystemInfo.deviceType == DeviceType.Handheld) {
                //Debug.LogWarning("Drag Begin");
                _gameGrid.PressPiece(this);
            }
        }
    }
}
