using System;
using System.Collections;
using System.Collections.Generic;
using Match3.FlutterUnityIntegration.Demo;
using UnityEngine;
using UnityEngine.SceneManagement;
using Random = UnityEngine.Random;

namespace Match3 {
	public class GameGrid : MonoBehaviour {
		private const float TimeBetweenDoingSomething = 2f; //Wait 2 second after we do something to do something again

		private const bool TestPowerUp = true;
		public int xDim;
		public int yDim;
		public float fillTime;

		public Level level;

		public PiecePrefab[] piecePrefabs;
		public GameObject backgroundPrefab;
		private bool _checkedMoves;
		private bool _powerupPlaced;
		private bool _powerupUsed;
		private GamePiece[,] _checkMovesArray;
		private IEnumerator _checkMovesCoroutine;
		private GamePiece _enteredPiece;

		private bool _gameOver;

		private bool _inverse;

		private bool _isFirst = true;

		private Dictionary<PieceType, GameObject> _piecePrefabDict;
		private GamePiece[,] _pieces;

		private GamePiece _pressedPiece;
		public GameObject pressedPieceAnimationPrefab;

		public AudioClip winningSound; // The sound to play when the player won the game
		public AudioClip losingSound; // The sound to play when the player lost the game
		public AudioClip loopingSound; // The sound to play while the game is playing
		public AudioClip swapSound; // The sound to play when pieces are swapped
		public AudioSource audioSource; // The AudioSource component

		private float _scale;

		private float _timeWhenWeNextDoSomething; //The next time we do something

		public bool IsFilling { get; private set; }

		private void Awake() {
			_mainCamera = Camera.main;
			// populating dictionary with piece prefabs types
			_piecePrefabDict = new Dictionary<PieceType, GameObject>();
			for (var i = 0; i < piecePrefabs.Length; i++)
				_piecePrefabDict.TryAdd(piecePrefabs[i].type, piecePrefabs[i].prefab);

			_timeWhenWeNextDoSomething = Time.time + TimeBetweenDoingSomething;
			audioSource = GetComponent<AudioSource>();

			audioSource.clip = loopingSound;
			audioSource.loop = true;
			if (GameManager.isMusicOn) {
				audioSource.volume = 0.5f;
				audioSource.Play();
			}
		}

		private void Update() {
			if (_timeWhenWeNextDoSomething <= Time.time)
				if (!_checkedMoves) {
					print("Checking for Moves at: " + Time.time);
					_checkMovesCoroutine = CheckMoves();
					StartCoroutine(_checkMovesCoroutine);
				}

			var currentScale = Screen.width < (float)Screen.height
				? Screen.width / (float)Screen.height
				: Screen.height / (float)Screen.width;
			if (Math.Abs(currentScale - _scale) > 0.0001f) {
				_scale = currentScale;
				ScaleCamera();
			}
		}

		private void ScaleCamera() {
			// Assuming each cell in the grid is 1 unit in size
			float gridSize = Mathf.Max(xDim, yDim); // The size of the grid in world units

			// Calculate the aspect ratio
			var screenRatio = (float)Screen.width / Screen.height;
			var targetRatio = gridSize / gridSize;

			if (screenRatio >= targetRatio) {
				_mainCamera.orthographicSize = gridSize / 2;
			} else {
				var differenceInSize = targetRatio / screenRatio;
				_mainCamera.orthographicSize = gridSize / 2 * differenceInSize;
			}

			var position = transform.position;
			var cameraTransform = _mainCamera.transform;
			var gridCenter = new Vector3(position.x + gridSize / 2, position.y + gridSize / 2,
				cameraTransform.position.z);
			cameraTransform.position = gridCenter - new Vector3(gridSize / 2, gridSize / 2, 0);
		}

		private IEnumerator CheckMoves() {
			if (!HasAvailableMoves()) {
				print("No More Moves");
				if (!level.isFlutter)
					ClearAll();
				else
					level.NoMoreMoves();
			}

			_checkedMoves = true;
			yield return null;
		}

		public void Instantiate() {
			// instantiate backgrounds
			for (var x = 0; x < xDim; x++)
				for (var y = 0; y < yDim; y++) {
					var background = Instantiate(backgroundPrefab, GetWorldPosition(x, y), Quaternion.identity);
					background.transform.parent = transform;
				}

			// instantiating pieces
			InstantiatePieces();
		}

		// private static float Remap(float value, float from1, float to1, float from2, float to2) {
		// 	return (value - from1) / (to1 - from1) * (to2 - from2) + from2;
		// }

		private void InstantiatePieces(bool firstTime = true) {
			_pieces = new GamePiece[xDim, yDim];
			print("Spawn Bubbles");
			var sceneInfo = SceneInfoExtensions.GetAsSceneInfo();
			if (!level.isFlutter && firstTime) {
				SpawnBubbles(10);
				level.SetNumOfObstacles();
			}

			if (sceneInfo.type == LevelType.Obstacle.ToString() && firstTime) {
				SpawnBubbles(sceneInfo.numOfObstacles);
				level.SetNumOfObstacles();
			}

			for (var x = 0; x < xDim; x++)
				for (var y = 0; y < yDim; y++)
					if (_pieces[x, y] == null)
						SpawnNewPiece(x, y, PieceType.Empty);

			StartCoroutine(Fill());
		}

		private void SpawnBubbles(int numOfObstacles) {
			for (var i = 0; i < numOfObstacles; i++) {
				var x = Random.Range(0, xDim);
				var y = Random.Range(0, yDim);
				while (_pieces[x, y] != null) {
					x = Random.Range(0, xDim);
					y = Random.Range(0, yDim);
				}

				SpawnNewPiece(x, y, PieceType.Bubble);
			}
		}

		private IEnumerator Fill() {
			var needsRefill = true;
			IsFilling = true;

			while (needsRefill) {
				yield return new WaitForSeconds(fillTime);
				while (FillStep()) {
					_inverse = !_inverse;
					yield return new WaitForSeconds(fillTime);
				}

				needsRefill = ClearAllValidMatches();
			}

			IsFilling = false;
			if (_isFirst) {
				var sceneInfo = SceneInfoExtensions.GetAsSceneInfo();
				int powerX, powerY;
				var powerUp = sceneInfo.powerUp;
				if (string.IsNullOrEmpty(powerUp)) {
					_powerupPlaced = true;
					_powerupUsed = true;
				}

				if (level.isFlutter && !string.IsNullOrEmpty(powerUp)) {
					print("PowerUpBought: " + powerUp);
					_timeWhenWeNextDoSomething = Time.time + 100000f;
					yield return new WaitUntil(() => _pressedPiece != null);
					powerX = _pressedPiece.X;
					powerY = _pressedPiece.Y;
					ClearPiece(powerX, powerY, false, false);
					if (powerUp.Contains("Clear")) {
						var realPowerUp = Random.Range(0, 2) == 0 ? PieceType.RowClear : PieceType.ColumnClear;
						var newPiece = SpawnNewPiece(powerX, powerY, realPowerUp);
						newPiece.ColorComponent.SetColor((ColorType)Random.Range(0,
							_pieces[0, 0].ColorComponent.NumColors));
					} else {
						var newPiece = SpawnNewPiece(powerX, powerY, PieceType.Rainbow);
						newPiece.ColorComponent.SetColor(ColorType.Any);
					}

					_powerupPlaced = true;
					_timeWhenWeNextDoSomething = Time.time + TimeBetweenDoingSomething;
				}

				if (!level.isFlutter && TestPowerUp) {
					_timeWhenWeNextDoSomething = Time.time + 100000f;
					print("TestPowerUp: " + TestPowerUp);
					// Wait for user input for powerup position
					yield return new WaitUntil(() => _pressedPiece != null);
					powerX = _pressedPiece.X;
					powerY = _pressedPiece.Y;
					ClearPiece(powerX, powerY);
					var newPiece = SpawnNewPiece(powerX, powerY, PieceType.Rainbow);
					newPiece.ColorComponent.SetColor(ColorType.Any);
					_timeWhenWeNextDoSomething = Time.time + 2f;
				}

				_isFirst = false;
				StartCoroutine(Fill());
			}

			yield return new WaitForSeconds(fillTime * 3);
		}

		// bool IsBubble(int x, int y) { return _pieces[x, y].Type == PieceType.Bubble; }

		/// <summary>
		///     One pass through all grid cells, moving them down one grid, if possible.
		/// </summary>
		/// <returns> returns true if at least one piece is moved down</returns>
		private bool FillStep() {
			var movedPiece = false;
			// y = 0 is at the top, we ignore the last row, since it can't be moved down.
			for (var y = yDim - 2; y >= 0; y--)
				for (var loopX = 0; loopX < xDim; loopX++) {
					var x = loopX;
					if (_inverse) x = xDim - 1 - loopX;
					var piece = _pieces[x, y];

					if (!piece.IsMovable()) continue;

					var pieceBelow = _pieces[x, y + 1];

					if (pieceBelow.Type == PieceType.Empty) {
						Destroy(pieceBelow.gameObject);
						piece.MovableComponent.Move(x, y + 1, fillTime);
						_pieces[x, y + 1] = piece;
						SpawnNewPiece(x, y, PieceType.Empty);
						movedPiece = true;
					} else
						for (var diag = -1; diag <= 1; diag++) {
							if (diag == 0) continue;

							var diagX = x + diag;

							if (_inverse) diagX = x - diag;

							if (diagX < 0 || diagX >= xDim) continue;

							var diagonalPiece = _pieces[diagX, y + 1];

							if (diagonalPiece.Type != PieceType.Empty) continue;

							var hasPieceAbove = true;

							for (var aboveY = y; aboveY >= 0; aboveY--) {
								var pieceAbove = _pieces[diagX, aboveY];

								if (pieceAbove.IsMovable()) break;
								if ( /*!pieceAbove.IsMovable() && */pieceAbove.Type != PieceType.Empty) {
									hasPieceAbove = false;
									break;
								}
							}

							if (hasPieceAbove) continue;

							Destroy(diagonalPiece.gameObject);
							piece.MovableComponent.Move(diagX, y + 1, fillTime);
							_pieces[diagX, y + 1] = piece;
							SpawnNewPiece(x, y, PieceType.Empty);
							movedPiece = true;
							break;
						}
				}

			// the highest row (0) is a special case, we must fill it with new pieces if empty
			for (var x = 0; x < xDim; x++) {
				var pieceBelow = _pieces[x, 0];

				if (pieceBelow.Type != PieceType.Empty) continue;

				Destroy(pieceBelow.gameObject);
				var newPiece = Instantiate(_piecePrefabDict[PieceType.Normal], GetWorldPosition(x, -1),
					Quaternion.identity);

				_pieces[x, 0] = newPiece.GetComponent<GamePiece>();
				_pieces[x, 0].Init(x, -1, this, PieceType.Normal);
				_pieces[x, 0].MovableComponent.Move(x, 0, fillTime);
				_pieces[x, 0].ColorComponent
					.SetColor((ColorType)Random.Range(0, _pieces[x, 0].ColorComponent.NumColors));
				movedPiece = true;
			}

			return movedPiece;
		}

		private bool HasAvailableMoves() {
			if (_pieces is null) return true;
			_checkMovesArray = _pieces.Clone() as GamePiece[,];

			for (var row = 0; row < xDim; row++)
				for (var col = 0; col < yDim; col++) {
					try {
						// Check horizontal swap
						if (_checkMovesArray != null) {
							var piece1 = _checkMovesArray[row, col];
							if (col < yDim - 1) {
								var piece2 = _checkMovesArray[row, col + 1];
								if (piece1 == null || piece2 == null) continue;
								if (piece1.Type == PieceType.Rainbow || piece2.Type == PieceType.Rainbow) {
									print("Rainbow Piece found");
									return true;
								}

								_checkMovesArray[row, col] = piece2;
								_checkMovesArray[row, col + 1] = piece1;
								if (HasMatchAt(row, col) || HasMatchAt(row, col + 1)) {
									_checkMovesArray[row, col] = piece1;
									_checkMovesArray[row, col + 1] = piece2;
									print("Found Move at Row: " + row + ", Col: " + col + ", Color " +
									      piece1.ColorComponent.Color +
									      ". With Row: " + row + " Col: " + (col + 1) + ", Color: " +
									      piece2.ColorComponent.Color + ".");
									return true;
								}

								_checkMovesArray[row, col] = piece1;
								_checkMovesArray[row, col + 1] = piece2;
							}

							// Check vertical swap
							if (row < xDim - 1) {
								var piece2 = _checkMovesArray[row + 1, col];
								if (piece1 == null || piece2 == null) continue;
								if (piece1.Type == PieceType.Rainbow || piece2.Type == PieceType.Rainbow) {
									print("Rainbow Piece found");
									return true;
								}

								_checkMovesArray[row, col] = piece2;
								_checkMovesArray[row + 1, col] = piece1;
								if (HasMatchAt(row, col) || HasMatchAt(row + 1, col)) {
									_checkMovesArray[row, col] = piece1;
									_checkMovesArray[row + 1, col] = piece2;
									print("Found Move at Row: " + row + ", Col: " + col + ", Color " +
									      piece1.ColorComponent.Color +
									      ". With Row: " + (row + 1) + " Col: " + col + ", Color: " +
									      piece2.ColorComponent.Color + ".");
									return true;
								}

								_checkMovesArray[row, col] = piece1;
								_checkMovesArray[row + 1, col] = piece2;
							}
						}
					} catch (Exception e) {
						Debug.LogWarning("Check if null-pointer appears here" + e);
					}
				}

			return false;
		}


		private bool HasMatchAt(int row, int col) {
			var piece = _checkMovesArray[row, col];

			// Check horizontal matches
			var startCol = col;
			var endCol = col;

			while (startCol >= 0 && piece.IsSameColor(_checkMovesArray[row, startCol])) startCol--;

			while (endCol < yDim && piece.IsSameColor(_checkMovesArray[row, endCol])) endCol++;

			if (endCol - startCol - 1 >= 3) return true;

			// Check vertical matches
			var startRow = row;
			var endRow = row;

			while (startRow >= 0 && piece.IsSameColor(_checkMovesArray[startRow, col])) startRow--;

			while (endRow < xDim && piece.IsSameColor(_checkMovesArray[endRow, col])) endRow++;

			if (endRow - startRow - 1 >= 3) return true;

			return false;
		}


		public Vector2 GetWorldPosition(int x, int y) {
			var transformPosition = transform.position;
			return new Vector2(
				transformPosition.x - xDim / 2.0f + x,
				transformPosition.y + yDim / 2.0f - y);
		}

		private GamePiece SpawnNewPiece(int x, int y, PieceType type) {
			var newPiece = Instantiate(_piecePrefabDict[type], GetWorldPosition(x, y), Quaternion.identity);
			_pieces[x, y] = newPiece.GetComponent<GamePiece>();
			_pieces[x, y].Init(x, y, this, type);

			return _pieces[x, y];
		}

		private static bool IsAdjacent(GamePiece piece1, GamePiece piece2) {
			return (piece1.X == piece2.X && Mathf.Abs(piece1.Y - piece2.Y) == 1) ||
			       (piece1.Y == piece2.Y && Mathf.Abs(piece1.X - piece2.X) == 1);
		}

		private void SwapPieces(GamePiece piece1, GamePiece piece2) {
			if (_gameOver) return;
			if (!piece1.IsMovable() || !piece2.IsMovable()) return;
			if (GameManager.isMusicOn) {
				audioSource.PlayOneShot(swapSound);
			}

			_pieces[piece1.X, piece1.Y] = piece2;
			_pieces[piece2.X, piece2.Y] = piece1;

			if (GetMatch(piece1, piece2.X, piece2.Y) != null ||
			    GetMatch(piece2, piece1.X, piece1.Y) != null ||
			    piece1.Type == PieceType.Rainbow ||
			    piece2.Type == PieceType.Rainbow) {
				var piece1X = piece1.X;
				var piece1Y = piece1.Y;

				piece1.MovableComponent.Move(piece2.X, piece2.Y, fillTime);
				piece2.MovableComponent.Move(piece1X, piece1Y, fillTime);

				if (piece1.Type == PieceType.Rainbow && piece1.IsClearable() && piece2.IsColored()) {
					var clearColor = piece1.GetComponent<ClearColorPiece>();

					if (clearColor) clearColor.Color = piece2.ColorComponent.Color;

					ClearPiece(piece1.X, piece1.Y);
				}

				if (piece2.Type == PieceType.Rainbow && piece2.IsClearable() && piece1.IsColored()) {
					var clearColor = piece2.GetComponent<ClearColorPiece>();

					if (clearColor) clearColor.Color = piece1.ColorComponent.Color;

					ClearPiece(piece2.X, piece2.Y);
				}

				ClearAllValidMatches();

				// special pieces get cleared, event if they are not matched
				if (piece1.Type == PieceType.RowClear || piece1.Type == PieceType.ColumnClear)
					ClearPiece(piece1.X, piece1.Y);

				if (piece2.Type == PieceType.RowClear || piece2.Type == PieceType.ColumnClear)
					ClearPiece(piece2.X, piece2.Y);

				_pressedPiece = null;
				_enteredPiece = null;

				StartCoroutine(Fill());

				level.OnMove();
			} else {
				var piece1X = piece1.X;
				var piece1Y = piece1.Y;

				var piece2X = piece2.X;
				var piece2Y = piece2.Y;
				StartCoroutine(FakeMove(piece1, piece2, true));

				_pieces[piece1X, piece1Y] = piece1;
				_pieces[piece2X, piece2Y] = piece2;
			}
		}

		private IEnumerator FakeMove(GamePiece piece1, GamePiece piece2, bool returnToOriginalPosition = false) {
			var piece1X = piece1.X;
			var piece1Y = piece1.Y;

			var piece2X = piece2.X;
			var piece2Y = piece2.Y;
			piece1.MovableComponent.Move(piece2X, piece2Y, fillTime);
			piece2.MovableComponent.Move(piece1X, piece1Y, fillTime);
			yield return new WaitForSeconds(fillTime);
			if (!returnToOriginalPosition) yield break;
			piece1.MovableComponent.Move(piece1X, piece1Y, fillTime);
			piece2.MovableComponent.Move(piece2X, piece2Y, fillTime);
		}


		private bool ClearAllValidMatches() {
			var needsRefill = false;

			for (var y = 0; y < yDim; y++)
				for (var x = 0; x < xDim; x++) {
					if (!_pieces[x, y].IsClearable()) continue;

					var match = GetMatch(_pieces[x, y], x, y);

					if (match == null) continue;

					var specialPieceType = PieceType.Count;
					var randomPiece = match[Random.Range(0, match.Count)];
					var specialPieceX = randomPiece.X;
					var specialPieceY = randomPiece.Y;

					// Spawning special pieces
					if (match.Count == 4) {
						if (_pressedPiece == null || _enteredPiece == null)
							specialPieceType =
								(PieceType)Random.Range((int)PieceType.RowClear, (int)PieceType.ColumnClear);
						else if (_pressedPiece.Y == _enteredPiece.Y)
							specialPieceType = PieceType.RowClear;
						else
							specialPieceType = PieceType.ColumnClear;
					} // Spawning a rainbow piece
					else if (match.Count >= 5) specialPieceType = PieceType.Rainbow;

					foreach (var gamePiece in match) {
						if (!ClearPiece(gamePiece.X, gamePiece.Y)) continue;

						needsRefill = true;

						if (gamePiece != _pressedPiece && gamePiece != _enteredPiece) continue;

						specialPieceX = gamePiece.X;
						specialPieceY = gamePiece.Y;
					}

					// Setting their colors
					if (specialPieceType == PieceType.Count) continue;

					Destroy(_pieces[specialPieceX, specialPieceY]);
					var newPiece = SpawnNewPiece(specialPieceX, specialPieceY, specialPieceType);

					switch (specialPieceType) {
						case PieceType.RowClear or PieceType.ColumnClear
							when newPiece.IsColored() && match[0].IsColored():
							newPiece.ColorComponent.SetColor(match[0].ColorComponent.Color);
							break;
						case PieceType.Rainbow when newPiece.IsColored():
							newPiece.ColorComponent.SetColor(ColorType.Any);
							break;
					}
				}

			return needsRefill;
		}

		private List<GamePiece> GetMatch(GamePiece piece, int newX, int newY) {
			if (!piece.IsColored()) return null;
			var color = piece.ColorComponent.Color;
			var horizontalPieces = new List<GamePiece>();
			var verticalPieces = new List<GamePiece>();
			var matchingPieces = new List<GamePiece>();

			// First check horizontal
			horizontalPieces.Add(piece);

			for (var dir = 0; dir <= 1; dir++)
				for (var xOffset = 1; xOffset < xDim; xOffset++) {
					int x;

					if (dir == 0) // Left
						x = newX - xOffset;
					else // right
						x = newX + xOffset;

					// out-of-bounds
					if (x < 0 || x >= xDim) break;

					// piece is the same color?
					if (_pieces[x, newY].IsColored() && _pieces[x, newY].ColorComponent.Color == color)
						horizontalPieces.Add(_pieces[x, newY]);
					else
						break;
				}

			if (horizontalPieces.Count >= 3) matchingPieces.AddRange(horizontalPieces);

			// Traverse vertically if we found a match (for L and T shape)
			if (horizontalPieces.Count >= 3)
				foreach (var gamePiece in horizontalPieces) {
					for (var dir = 0; dir <= 1; dir++)
						for (var yOffset = 1; yOffset < yDim; yOffset++) {
							int y;

							if (dir == 0) // Up
								y = newY - yOffset;
							else // Down
								y = newY + yOffset;

							if (y < 0 || y >= yDim) break;

							if (_pieces[gamePiece.X, y].IsColored() &&
							    _pieces[gamePiece.X, y].ColorComponent.Color == color)
								verticalPieces.Add(_pieces[gamePiece.X, y]);
							else
								break;
						}

					if (verticalPieces.Count < 2)
						verticalPieces.Clear();
					else {
						matchingPieces.AddRange(verticalPieces);
						break;
					}
				}

			if (matchingPieces.Count >= 3) return matchingPieces;


			// Didn't find anything going horizontally first,
			// so now check vertically
			horizontalPieces.Clear();
			verticalPieces.Clear();
			verticalPieces.Add(piece);

			for (var dir = 0; dir <= 1; dir++)
				for (var yOffset = 1; yOffset < xDim; yOffset++) {
					int y;

					if (dir == 0) // Up
						y = newY - yOffset;
					else // Down
						y = newY + yOffset;

					// out-of-bounds
					if (y < 0 || y >= yDim) break;

					// piece is the same color?
					if (_pieces[newX, y].IsColored() && _pieces[newX, y].ColorComponent.Color == color)
						verticalPieces.Add(_pieces[newX, y]);
					else
						break;
				}

			if (verticalPieces.Count >= 3) matchingPieces.AddRange(verticalPieces);

			// Traverse horizontally if we found a match (for L and T shape)
			if (verticalPieces.Count >= 3)
				foreach (var gamePiece in verticalPieces) {
					for (var dir = 0; dir <= 1; dir++)
						for (var xOffset = 1; xOffset < yDim; xOffset++) {
							int x;

							if (dir == 0) // Left
								x = newX - xOffset;
							else // Right
								x = newX + xOffset;

							if (x < 0 || x >= xDim) break;

							if (_pieces[x, gamePiece.Y].IsColored() &&
							    _pieces[x, gamePiece.Y].ColorComponent.Color == color)
								horizontalPieces.Add(_pieces[x, gamePiece.Y]);
							else
								break;
						}

					if (horizontalPieces.Count < 2)
						horizontalPieces.Clear();
					else {
						matchingPieces.AddRange(horizontalPieces);
						break;
					}
				}

			if (matchingPieces.Count >= 3) return matchingPieces;

			return null;
		}

		private bool ClearPiece(int x, int y, bool includePoints = true, bool clearBubble = true) {
			if (_pieces[x, y] == null) {
				return false;
			}

			if (!_pieces[x, y].IsClearable() || _pieces[x, y].ClearableComponent.IsBeingCleared) return false;
			_pieces[x, y].ClearableComponent.Clear(includePoints);
			SpawnNewPiece(x, y, PieceType.Empty);

			if (clearBubble) {
				ClearObstacles(x, y);
			}

			return true;
		}

		private void ClearObstacles(int x, int y) {
			for (var adjacentX = x - 1; adjacentX <= x + 1; adjacentX++) {
				if (adjacentX == x || adjacentX < 0 || adjacentX >= xDim) continue;

				if (_pieces[adjacentX, y].Type != PieceType.Bubble || !_pieces[adjacentX, y].IsClearable()) continue;

				_pieces[adjacentX, y].ClearableComponent.Clear(true);
				SpawnNewPiece(adjacentX, y, PieceType.Empty);
			}

			for (var adjacentY = y - 1; adjacentY <= y + 1; adjacentY++) {
				if (adjacentY == y || adjacentY < 0 || adjacentY >= yDim) continue;

				if (_pieces[x, adjacentY].Type != PieceType.Bubble || !_pieces[x, adjacentY].IsClearable()) continue;

				_pieces[x, adjacentY].ClearableComponent.Clear(true);
				SpawnNewPiece(x, adjacentY, PieceType.Empty);
			}
		}

		public void ClearAll() {
			for (var x = 0; x < xDim; x++)
				for (var y = 0; y < yDim; y++)
					if (_pieces[x, y].Type != PieceType.Bubble) // Check if the piece is not a bubble before clearing
						ClearPiece(x, y, false, false);
			StartCoroutine(Fill());
			_checkedMoves = false;
			StopCoroutine(_checkMovesCoroutine);
			_timeWhenWeNextDoSomething = Time.time + TimeBetweenDoingSomething;
		}

		public void ClearRow(int row) {
			for (var x = 0; x < xDim; x++) ClearPiece(x, row);
		}

		public void ClearColumn(int column) {
			for (var y = 0; y < yDim; y++) ClearPiece(column, y);
		}

		public void ClearColor(ColorType color) {
			for (var x = 0; x < xDim; x++)
				for (var y = 0; y < yDim; y++)
					if ((_pieces[x, y].IsColored() && _pieces[x, y].ColorComponent.Color == color)
					    || color == ColorType.Any)
						ClearPiece(x, y);
		}

		public void GameOver(bool gameWon) {
			if (GameManager.isMusicOn) {
				audioSource.Stop();
				audioSource.PlayOneShot(gameWon ? winningSound : losingSound);
			}

			_gameOver = true;
		}


		public List<GamePiece> GetPiecesOfType(PieceType type) {
			var piecesOfType = new List<GamePiece>();

			for (var x = 0; x < xDim; x++)
				for (var y = 0; y < yDim; y++)
					if (_pieces?[x, y] != null && _pieces[x, y].Type == type)
						piecesOfType.Add(_pieces[x, y]);

			return piecesOfType;
		}

		public GamePiece GetPieceAt(int x, int y) { return _pieces[x, y]; }

		public List<GamePiece> GetPiecesOfColor(ColorType colorType) {
			var piecesOfColor = new List<GamePiece>();

			for (var x = 0; x < xDim; x++)
				for (var y = 0; y < yDim; y++)
					if (_pieces[x, y].ColorComponent.Color == colorType)
						piecesOfColor.Add(_pieces[x, y]);

			return piecesOfColor;
		}

		private GameObject _currentPressedPieceAnimation;
		private Camera _mainCamera;

		public void PressPiece(GamePiece piece) {
			_timeWhenWeNextDoSomething = Time.time + 100f;
			_pressedPiece = piece;
			print("Piece at X: " + _pressedPiece.X + ", Y: " + _pressedPiece.Y + ", Color: " +
			      _pressedPiece.ColorComponent.Color);

			// If there is an existing PoisonGas, destroy it
			if (_currentPressedPieceAnimation != null) {
				Destroy(_currentPressedPieceAnimation);
			}

			// Instantiate the PoisonGas Prefab at the position of the pressed piece
			var position = GetWorldPosition(_pressedPiece.X, _pressedPiece.Y);
			position.x += 0.5f;
			position.y -= 0.5f;
			Vector3 poisonGasPosition = new Vector3(position.x, position.y, .1f);
			_currentPressedPieceAnimation =
				Instantiate(pressedPieceAnimationPrefab, poisonGasPosition, Quaternion.identity);

			// Scale down the PoisonGas prefab
			_currentPressedPieceAnimation.transform.localScale =
				new Vector3(0.05f, 0.05f, 0.05f); // Scale down by 1000x
		}

		public void EnterPiece(GamePiece piece) { _enteredPiece = piece; }

		public void ReleasePiece() {
			if (IsFilling) {
				Debug.Log("Still Filling");
				return;
			}

			if (_isFirst) {
				Debug.Log("Still Waiting for PowerUp");
				if (GetPiecesOfType(PieceType.Rainbow).Count > 0)
					_isFirst = false;
				return;
			}

			if (!_powerupPlaced || !_powerupUsed) {
				_powerupPlaced = true;
				_powerupUsed = true;
				return;
			}

			if (IsAdjacent(_pressedPiece, _enteredPiece)) SwapPieces(_pressedPiece, _enteredPiece);

			_checkedMoves = false;
			_timeWhenWeNextDoSomething = Time.time + TimeBetweenDoingSomething;
		}

		[Serializable]
		public struct PiecePrefab {
			public PieceType type;
			public GameObject prefab;
		}

		[Serializable]
		public struct PiecePosition {
			public PieceType type;
			public int x;
			public int y;
		}
	}
}