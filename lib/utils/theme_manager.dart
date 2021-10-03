import 'package:flutter/material.dart';
import './storage_manager.dart';
import 'package:zimple/utils/constants.dart';

class ThemeNotifier with ChangeNotifier {
  final darkTheme = ThemeData(
      primarySwatch: Colors.grey,
      primaryColor: Colors.black,
      brightness: Brightness.dark,
      backgroundColor: Color(0xff121212),
      scaffoldBackgroundColor: Color(0xff121212),
      cardColor: Color(0xff282828),
      accentColor: Colors.indigo.shade600,
      buttonColor: green,
      accentIconTheme: IconThemeData(color: Colors.black),
      dividerColor: Colors.white,
      fontFamily: 'FiraSans',
      iconTheme: IconThemeData(color: Colors.white),
      shadowColor: Colors.black.withOpacity(0.1),
      bottomAppBarColor: Colors.black);

  final lightTheme = ThemeData(
    primarySwatch: Colors.grey,
    primaryColor: Colors.white,
    brightness: Brightness.light,
    backgroundColor: Colors.white,
    accentColor: Colors.lightBlue,
    buttonColor: green,
    accentIconTheme: IconThemeData(color: Colors.white),
    dividerColor: Colors.black,
    fontFamily: 'FiraSans',
    iconTheme: IconThemeData(color: Colors.black),
    shadowColor: Colors.grey.withOpacity(0.10),
    bottomAppBarColor: Color(0xffF4F7FB),
  );

  ThemeNotifier() {
    _themeData = lightTheme;
    StorageManager.readData('themeMode').then((value) {
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
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    StorageManager.saveData('themeMode', 'light');
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
