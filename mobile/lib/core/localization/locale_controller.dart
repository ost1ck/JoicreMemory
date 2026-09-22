import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(this._preferences);
  static const preferenceKey = 'joicrememory_language';
  final SharedPreferences _preferences;

  String get languageCode {
    final saved = _preferences.getString(preferenceKey);
    return const ['uk', 'en', 'system'].contains(saved) ? saved! : 'uk';
  }

  Locale? get locale => languageCode == 'system' ? null : Locale(languageCode);

  Future<void> setLanguage(String value) async {
    if (!const ['uk', 'en', 'system'].contains(value)) return;
    await _preferences.setString(preferenceKey, value);
    notifyListeners();
  }
}
