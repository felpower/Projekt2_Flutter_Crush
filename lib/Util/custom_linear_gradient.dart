import 'package:flutter/material.dart';

class CustomLinearGradient {
  static LinearGradient gradient = LinearGradient(
    begin: Alignment.topCenter, // new
    end: Alignment.bottomCenter, // new
    // Add one stop for each color.
    // Stops should increase
    // from 0 to 1
    stops: [0.1, 0.5, 0.7, 0.9],
    colors: [
      // Colors are easy thanks to Flutter's
      // Colors class.
      Colors.white,
      Colors.grey[100]!,
      Colors.grey[200]!,
      Colors.grey[300]!,
    ],
  );
}
