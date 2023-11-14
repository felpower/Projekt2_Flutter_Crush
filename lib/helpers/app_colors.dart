import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color cardBgColor = Color(0xff363636);
  static const Color colorB58D67 = Color(0xffB58D67);
  static const Color colorE5D1B2 = Color(0xffE5D1B2);
  static const Color colorF9EED2 = Color(0xffF9EED2);
  static const Color colorFFFFFD = Color(0xffFFFFFD);

  static getColorLevel(int level) {
    if (level > 30) {
      level -= 30;
    }
    int number = (level / 6).floor();
    if (level % 6 == 0) {
      number--;
    }
    return getColor(number);
  }

  static Color getColorFortune(int number) {
    return getColor(number % 6);
  }

  static getColor(number) {
    if (number == 0) {
      return Colors.red;
    } else if (number == 1) {
      return Colors.blue;
    } else if (number == 2) {
      return Colors.green;
    } else if (number == 3) {
      return Colors.yellow;
    } else if (number == 4) {
      return Colors.purple;
    } else if (number == 5) {
      return Colors.tealAccent;
    } else {
      return Colors.orangeAccent;
    }
  }
}
