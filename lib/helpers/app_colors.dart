import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static getColorLevel(int level) {
    // Normalize level to a 0-based index for easier calculation
    int levelIndex = (level - 1) % 30; // This will map levels 1-30 to 0-29 repeatedly
    // Calculate the color number based on the levelIndex, where each group of 6 levels gets a unique number
    int colorIndex = levelIndex ~/ 6; // This will map levels 0-5 to 0, 6-11 to 1, etc.
    return getColor(colorIndex);
  }

  static getColor(int number) {
    List<String> hexColors = [
      "#fdc300", // color for numbers 0, 6, 12, ...
      "#b14895", // color for numbers 1, 7, 13, ...
      "#e52012", // color for numbers 2, 8, 14, ...
      "#86ae1d", // color for numbers 3, 9, 15, ...
      "#1787ba", // color for numbers 4, 10, 16, ...
      "#ef82a9", // color for numbers 5, 11, 17, ...
    ];

    // Use modulo operation to wrap around the number if it exceeds the length of hexColors
    String hexColor = hexColors[number % hexColors.length];
    return getColorFromHex(hexColor);
  }

  static Color getColorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static Color getColorFortune(int number) {
    return getColor(number % 6);
  }
}
