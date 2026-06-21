import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleState extends ChangeNotifier {
  LocaleState._(this._locale) {
    activeLanguageCode = _locale.languageCode;
  }

  factory LocaleState.forTest([Locale locale = const Locale('en')]) {
    return LocaleState._(locale);
  }

  static const preferenceKey = 'app_language';
  static const supportedLanguageCodes = <String>{'en', 'es', 'ca'};
  static String activeLanguageCode = 'en';

  Locale _locale;

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  static Future<LocaleState> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedLanguage = preferences.getString(preferenceKey);
    final deviceLanguage = PlatformDispatcher.instance.locale.languageCode
        .toLowerCase();
    final languageCode = _supported(storedLanguage)
        ? storedLanguage!.toLowerCase().substring(0, 2)
        : _supported(deviceLanguage)
        ? deviceLanguage.substring(0, 2)
        : 'en';

    return LocaleState._(Locale(languageCode));
  }

  Future<void> setLanguage(String languageCode) async {
    if (languageCode.length < 2) return;
    final normalized = languageCode.toLowerCase().substring(0, 2);
    if (!_supported(normalized) || normalized == _locale.languageCode) {
      return;
    }

    _locale = Locale(normalized);
    activeLanguageCode = normalized;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(preferenceKey, normalized);
  }

  static bool _supported(String? languageCode) {
    if (languageCode == null || languageCode.length < 2) {
      return false;
    }
    return supportedLanguageCodes.contains(
      languageCode.toLowerCase().substring(0, 2),
    );
  }
}
