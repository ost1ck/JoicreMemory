import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._preferences);
  static const _key = 'joicrememory_dark_theme';
  final SharedPreferences _preferences;
  bool get isDark => _preferences.getBool(_key) ?? false;
  ThemeMode get mode => isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDark(bool value) async {
    await _preferences.setBool(_key, value);
    notifyListeners();
  }
}
