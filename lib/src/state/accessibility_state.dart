import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AccessibilityColorMode {
  none,
  monochrome,
  darkContrast,
  lightContrast,
  lowSaturation,
  highSaturation,
  highContrast,
}

class AccessibilityState extends ChangeNotifier {
  static const _colorModeKey = 'accessibility_color_mode';
  static const _fontLevelKey = 'accessibility_font_level';
  static const _lineSpacingKey = 'accessibility_line_spacing';
  static const _wordSpacingKey = 'accessibility_word_spacing';
  static const _letterSpacingKey = 'accessibility_letter_spacing';

  AccessibilityColorMode _colorMode = AccessibilityColorMode.none;

  int _fontLevel = 0;
  bool _lineSpacing = false;
  bool _wordSpacing = false;
  bool _letterSpacing = false;

  AccessibilityColorMode get colorMode => _colorMode;

  int get fontLevel => _fontLevel;
  bool get lineSpacing => _lineSpacing;
  bool get wordSpacing => _wordSpacing;
  bool get letterSpacing => _letterSpacing;

  double get textScale => 1 + (_fontLevel * 0.08);

  double? get lineHeight => _lineSpacing ? 1.8 : null;
  double? get wordSpacingValue => _wordSpacing ? 10 : null;
  double? get letterSpacingValue => _letterSpacing ? 2.8 : null;

  TextStyle get textAdjustments {
    return TextStyle(
      height: lineHeight,
      wordSpacing: wordSpacingValue,
      letterSpacing: letterSpacingValue,
    );
  }

  bool get forceDarkUi =>
      _colorMode == AccessibilityColorMode.darkContrast ||
      _colorMode == AccessibilityColorMode.highContrast;

  Color get pageBackgroundColor {
    switch (_colorMode) {
      case AccessibilityColorMode.darkContrast:
        return const Color(0xFF071224);
      case AccessibilityColorMode.highContrast:
        return Colors.black;
      case AccessibilityColorMode.lightContrast:
        return Colors.white;
      default:
        return const Color(0xFFF7F8FB);
    }
  }

  Color get surfaceColor {
    switch (_colorMode) {
      case AccessibilityColorMode.darkContrast:
        return const Color(0xFF1E293B);
      case AccessibilityColorMode.highContrast:
        return Colors.black;
      case AccessibilityColorMode.lightContrast:
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  Color get secondarySurfaceColor {
    switch (_colorMode) {
      case AccessibilityColorMode.darkContrast:
        return const Color(0xFF243247);
      case AccessibilityColorMode.highContrast:
        return Colors.black;
      case AccessibilityColorMode.lightContrast:
        return const Color(0xFFF8FAFC);
      default:
        return const Color(0xFFF7F8FB);
    }
  }

  Color get inputFillColor {
    switch (_colorMode) {
      case AccessibilityColorMode.darkContrast:
        return const Color(0xFF0F172A);
      case AccessibilityColorMode.highContrast:
        return Colors.black;
      case AccessibilityColorMode.lightContrast:
        return Colors.white;
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color get textColor {
    switch (_colorMode) {
      case AccessibilityColorMode.darkContrast:
      case AccessibilityColorMode.highContrast:
        return Colors.white;
      default:
        return const Color(0xFF111827);
    }
  }

  Color get secondaryTextColor {
    switch (_colorMode) {
      case AccessibilityColorMode.darkContrast:
        return const Color(0xFFE5E7EB);
      case AccessibilityColorMode.highContrast:
        return Colors.white;
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color get borderColor {
    switch (_colorMode) {
      case AccessibilityColorMode.darkContrast:
        return const Color(0xFF475569);
      case AccessibilityColorMode.highContrast:
        return Colors.white;
      case AccessibilityColorMode.lightContrast:
        return const Color(0xFFD1D5DB);
      default:
        return const Color(0xFFD9E0EA);
    }
  }

  Color get buttonColor {
    switch (_colorMode) {
      case AccessibilityColorMode.darkContrast:
      case AccessibilityColorMode.highContrast:
        return Colors.white;
      default:
        return const Color(0xFF111827);
    }
  }

  Color get buttonTextColor {
    switch (_colorMode) {
      case AccessibilityColorMode.darkContrast:
      case AccessibilityColorMode.highContrast:
        return Colors.black;
      default:
        return Colors.white;
    }
  }

  ColorFilter? get colorFilter {
    switch (_colorMode) {
      case AccessibilityColorMode.none:
      case AccessibilityColorMode.darkContrast:
      case AccessibilityColorMode.lightContrast:
      case AccessibilityColorMode.highContrast:
        return null;

      case AccessibilityColorMode.monochrome:
        return const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);

      case AccessibilityColorMode.lowSaturation:
        return _saturationFilter(0.25);

      case AccessibilityColorMode.highSaturation:
        return _saturationFilter(2.2);
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _colorMode =
        AccessibilityColorMode.values[prefs.getInt(_colorModeKey) ??
            AccessibilityColorMode.none.index];
    _fontLevel = prefs.getInt(_fontLevelKey) ?? 0;
    _lineSpacing = prefs.getBool(_lineSpacingKey) ?? false;
    _wordSpacing = prefs.getBool(_wordSpacingKey) ?? false;
    _letterSpacing = prefs.getBool(_letterSpacingKey) ?? false;

    notifyListeners();
  }

  Future<void> setColorMode(AccessibilityColorMode mode) async {
    _colorMode = _colorMode == mode ? AccessibilityColorMode.none : mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorModeKey, _colorMode.index);
  }

  Future<void> increaseFont() async {
    if (_fontLevel >= 5) return;
    _fontLevel++;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontLevelKey, _fontLevel);
  }

  Future<void> decreaseFont() async {
    if (_fontLevel <= 0) return;
    _fontLevel--;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontLevelKey, _fontLevel);
  }

  Future<void> toggleLineSpacing() async {
    _lineSpacing = !_lineSpacing;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lineSpacingKey, _lineSpacing);
  }

  Future<void> toggleWordSpacing() async {
    _wordSpacing = !_wordSpacing;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_wordSpacingKey, _wordSpacing);
  }

  Future<void> toggleLetterSpacing() async {
    _letterSpacing = !_letterSpacing;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_letterSpacingKey, _letterSpacing);
  }

  Future<void> reset() async {
    _colorMode = AccessibilityColorMode.none;
    _fontLevel = 0;
    _lineSpacing = false;
    _wordSpacing = false;
    _letterSpacing = false;

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_colorModeKey);
    await prefs.remove(_fontLevelKey);
    await prefs.remove(_lineSpacingKey);
    await prefs.remove(_wordSpacingKey);
    await prefs.remove(_letterSpacingKey);
  }

  static ColorFilter _saturationFilter(double saturation) {
    final inv = 1 - saturation;
    final r = 0.2126 * inv;
    final g = 0.7152 * inv;
    final b = 0.0722 * inv;

    return ColorFilter.matrix(<double>[
      r + saturation,
      g,
      b,
      0,
      0,
      r,
      g + saturation,
      b,
      0,
      0,
      r,
      g,
      b + saturation,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);
  }
}
