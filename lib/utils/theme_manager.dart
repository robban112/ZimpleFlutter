import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'zpreferences.dart';

class ThemeNotifier with ChangeNotifier {
  static ThemeNotifier of(BuildContext context) {
    return context.watch<ThemeNotifier>();
  }

  Color get textColor {
    return isDarkMode() ? Colors.white : Colors.black;
  }

  Color get yellow {
    return isDarkMode() ? Color(0xffFEC260) : Colors.yellow.shade500;
  }

  Color get photoButtonColor {
    return isDarkMode() ? Color(0xff191A19) : Color.fromARGB(255, 240, 240, 240);
  }

  Color get red {
    return Color.fromARGB(255, 247, 90, 132);
  }

  Color get green {
    return Color.fromARGB(255, 19, 173, 119);
  }

  static final Color lightThemePrimaryBg = Color(0xffFCFCFF);

  static final Color darkThemePrimaryBg = Color(0xff0F0E0E);

  late final darkTheme = ThemeData(
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
      ),
      primarySwatch: Colors.grey,
      primaryColor: Colors.black,
      scaffoldBackgroundColor: darkThemePrimaryBg,
      backgroundColor: darkThemePrimaryBg,
      cardColor: Color(0xff191A19),
      primaryIconTheme: IconThemeData(color: Colors.white),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo).copyWith(
        secondary: Color(0xFF3949AB),
        brightness: Brightness.dark,
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ),
      accentIconTheme: IconThemeData(color: Colors.black),
      dividerColor: Colors.white,
      fontFamily: 'FiraSans',
      iconTheme: IconThemeData(color: Colors.white),
      shadowColor: Colors.black.withOpacity(0.1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkThemePrimaryBg,
      ),
      bottomAppBarColor: Color(0xff0F0E0E));

  late final lightTheme = ThemeData(
    primarySwatch: Colors.grey,
    primaryColor: lightThemePrimaryBg,
    scaffoldBackgroundColor: lightThemePrimaryBg,
    backgroundColor: lightThemePrimaryBg,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.lightBlue).copyWith(
      secondary: Color(0xff3617F9),
      brightness: Brightness.light,
    ),
    cardColor: Colors.white,
    snackBarTheme: SnackBarThemeData(
      actionTextColor: Colors.white,
    ),
    //accentColor: Colors.lightBlue,
    primaryIconTheme: IconThemeData(color: Colors.white),
    dividerColor: Colors.black,
    fontFamily: 'FiraSans',
    iconTheme: IconThemeData(color: Colors.black),
    shadowColor: Colors.grey.withOpacity(0.10),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkThemePrimaryBg,
    ),
    bottomAppBarColor: lightThemePrimaryBg,
  );

  ThemeNotifier() {
    _themeData = lightTheme;
    ZPreferences.readData(Keys.themeMode).then((value) {
      print('value read from storage: ' + value.toString());
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        print('setting light theme');
        _themeData = lightTheme;
      } else {
        print('setting dark theme');
        _themeData = darkTheme;
      }
      notifyListeners();
    });
  }

  late ThemeData _themeData;
  ThemeData getTheme() => _themeData;

  void setDarkMode() async {
    _themeData = darkTheme;
    ZPreferences.saveData(Keys.themeMode, 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    ZPreferences.saveData(Keys.themeMode, 'light');
    notifyListeners();
  }

  String getThemeString() {
    if (_themeData == lightTheme)
      return 'light';
    else
      return 'dark';
  }

  bool isDarkMode() {
    return _themeData != lightTheme;
  }
}
