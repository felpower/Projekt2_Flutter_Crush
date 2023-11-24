import 'package:flutter/material.dart';
class AppColors {
  AppColors._();

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
      return getColorFromHex("#fdc300");
    } else if (number == 1) {
      return getColorFromHex("#b14895");
    } else if (number == 2) {
      return getColorFromHex("#e52012");
    } else if (number == 3) {
      return getColorFromHex("#86ae1d");
    } else if (number == 4) {
      return getColorFromHex("#1787ba");
    } else if (number == 5) {
      return getColorFromHex("#ef82a9");
    } else {
      return getColorFromHex("#b14895");
    }
  }

  static int getColorCodeFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }

    final hexNum = int.parse(hexColor, radix: 16);

    if (hexNum == 0) {
      return 0xff000000;
    }

    return hexNum;
  }

  static Color getColorFromHex(String hexColor){
    return Color(getColorCodeFromHex(hexColor));
  }


}
