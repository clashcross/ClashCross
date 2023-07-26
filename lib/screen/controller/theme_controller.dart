import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';

enum ThemeType { light, dark }

class ThemeController123 extends GetxController  {




  Map<int, Color> _colorSwatch(
      int r,
      int g,
      int b,
      ) =>
      {
        50: Color.fromRGBO(r, g, b, 0.1),
        100: Color.fromRGBO(r, g, b, 0.2),
        200: Color.fromRGBO(r, g, b, 0.3),
        300: Color.fromRGBO(r, g, b, 0.4),
        400: Color.fromRGBO(r, g, b, 0.5),
        500: Color.fromRGBO(r, g, b, 0.6),
        600: Color.fromRGBO(r, g, b, 0.7),
        700: Color.fromRGBO(r, g, b, 0.8),
        800: Color.fromRGBO(r, g, b, 0.9),
        900: Color.fromRGBO(r, g, b, 1),
      };
  bool isDarkActive = SpUtil.getData<bool>("dark_theme", defValue: false);



  ThemeData get getActiveTheme => isDarkActive ? _darkTheme : _lightTheme;

// Let's define a light theme for our Application
  ThemeData get _lightTheme => ThemeData(
      primaryColor: const Color(0xff6622CC),
      canvasColor: const Color(0xffFFFFFF),
      backgroundColor: const Color(0xffFFFFFF),
      iconTheme: const IconThemeData(color: Colors.black87),
      primaryTextTheme: TextTheme(
          bodyText1: const TextStyle(color: Colors.black, fontSize: 15),
          bodyText2: const TextStyle(color: Colors.black54, fontSize: 15),
          subtitle1: const TextStyle(color: Colors.black),
          headline3: const TextStyle(
              color: Colors.black, fontSize: 27, fontWeight: FontWeight.bold),
          headline6: const TextStyle(color: Colors.black),
          caption: TextStyle(
              color: Colors.grey.shade700, wordSpacing: -1, fontSize: 12)),
      colorScheme: ColorScheme.fromSwatch(
          primarySwatch:
          MaterialColor(0xffFFFFFF, _colorSwatch(1, 117, 194)))
          .copyWith(secondary: const Color(0xffAE77FF)));

// Now define a dark theme for our Application
  ThemeData get _darkTheme => ThemeData(
      primaryColor: const Color(0xff6622CC),
      canvasColor: const Color(0xff0B0415),
      backgroundColor: const Color(0xff0B0415),
      iconTheme: const IconThemeData(color: Colors.white),
      primaryTextTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.white, fontSize: 15),
          bodyText2: TextStyle(color: Colors.white70, fontSize: 15),
          subtitle1: TextStyle(color: Colors.white),
          headline3: TextStyle(
              color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
          headline6: TextStyle(color: Colors.white),
          caption:
          TextStyle(color: Colors.white54, wordSpacing: -1, fontSize: 12)),
      colorScheme: ColorScheme.fromSwatch(
          primarySwatch:
          MaterialColor(0xff0B0415, _colorSwatch(2, 86, 155)))
          .copyWith(secondary: const Color(0xffAE77FF)));



  ThemeMode getThemeMode() {
    final darkMode = isDarkActive;
    switch (darkMode) {
      // case null:
      //   return ThemeMode.system;
      case true:
        return ThemeMode.dark;
      case false:
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  changeTheme(ThemeType type) {
    switch (type) {
      case ThemeType.light:
        // Get.changeThemeMode(ThemeMode.light);
        isDarkActive=false;
        SpUtil.setData<bool>('dark_theme', false);
        break;
      case ThemeType.dark:
        // Get.changeThemeMode(ThemeMode.dark);
        isDarkActive=true;
        SpUtil.setData<bool>('dark_theme', true);
        break;
    }
  }
}
