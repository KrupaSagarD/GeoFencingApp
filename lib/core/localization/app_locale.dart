
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocale {
  AppLocale._();

  static const String _localeKey = 'officecheck_app_locale';

  static final ValueNotifier<Locale> locale =
  ValueNotifier(const Locale('en'));

  static Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_localeKey) ?? 'en';

    locale.value = Locale(savedCode == 'ja' ? 'ja' : 'en');
  }

  static Future<void> changeLocale(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'ja') return;

    locale.value = Locale(languageCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }
}
