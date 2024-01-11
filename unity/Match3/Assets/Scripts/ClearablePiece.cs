using System.Collections;
using UnityEngine;
using UnityEngine.Serialization;

namespace Match3 {
	public class ClearablePiece : MonoBehaviour {
		public AnimationClip clearAnimation;
		protected GamePiece piece;

		public bool IsBeingCleared { get; private set; }

		private void Awake() {
			piece = GetComponent<GamePiece>();
		}

		public virtual void Clear(bool includePoints) {
			piece.GameGridRef.level.OnPieceCleared(piece, includePoints);
			IsBeingCleared = true;
			StartCoroutine(ClearCoroutine());
		}

		private IEnumerator ClearCoroutine() {
			var clearAnimator = GetComponent<Animator>();

			if (clearAnimator) {
				clearAnimator.Play(clearAnimation.name);

				yield return new WaitForSeconds(clearAnimation.length);

				Destroy(gameObject);
			}
		}
	}
}