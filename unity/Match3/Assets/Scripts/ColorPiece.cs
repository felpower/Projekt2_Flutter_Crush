using System;
using System.Collections.Generic;
using UnityEngine;
namespace Match3
{
    public class ColorPiece : MonoBehaviour
    {

        public ColorSprite[] colorSprites;

        private ColorType _color;
        private Dictionary<ColorType, Sprite> _colorSpriteDict;

        private SpriteRenderer _sprite;

        public ColorType Color
        {
            get => _color;
            set => SetColor(value);
        }

        public int NumColors => colorSprites.Length;

        private void Awake()
        {
            _sprite = transform.Find("piece").GetComponent<SpriteRenderer>();

            // instantiating and populating a Dictionary of all Color Types / Sprites (for fast lookup)
            _colorSpriteDict = new Dictionary<ColorType, Sprite>();

            for (int i = 0; i < colorSprites.Length; i++) {
                _colorSpriteDict.TryAdd(colorSprites[i].color, colorSprites[i].sprite);
            }
        }

        public void SetColor(ColorType newColor)
        {
            _color = newColor;

            if (_colorSpriteDict.TryGetValue(newColor, out Sprite value)) {
                _sprite.sprite = value;
            }
        }
        [Serializable]
        public struct ColorSprite
        {
            public ColorType color;
            public Sprite sprite;
        }
    }
}
