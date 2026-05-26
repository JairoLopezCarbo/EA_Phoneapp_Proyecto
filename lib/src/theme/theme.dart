import 'package:flutter/material.dart';

// Values mirror webapp/src/styles/theme.css.
class AppFonts {
  const AppFonts._();

  static const String sans = 'Arial Rounded MT Bold';
  static const List<String> sansFallback = [
    'Arial Rounded MT',
    'Arial',
  ];

  static const String sansAlt = 'Trebuchet MS';
  static const List<String> sansAltFallback = [
    'Century Gothic',
    'Arial Rounded MT Bold',
  ];
}

class AppColors {
  const AppColors._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0F1219);

  static const Color background = Color(0xFFF3F4F6);
  static const Color backgroundSoft = Color(0xFFF7F8FB);
  static const Color backgroundSoft2 = Color(0xFFF2F3F7);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF6F7FB);
  static const Color surfaceSubtle = Color(0xFFF0F2F7);
  static const Color surfaceAlt = Color(0xFFECECF1);
  static const Color surfaceGlass = Color(0xF5FFFFFF);
  static const Color surfaceGlass95 = Color(0xF2FFFFFF);
  static const Color surfaceGlassStrong = Color(0xEBFFFFFF);
  static const Color surfaceGlassSoft = Color(0xDBFFFFFF);

  static const Color text = Color(0xFF131318);
  static const Color textStrong = Color(0xFF0F1219);
  static const Color textSecondary = Color(0xFF2D3340);
  static const Color textBody = Color(0xFF303548);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textSubtle = Color(0xFF39465F);
  static const Color textContrast = Color(0xFF111827);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE5E7EF);
  static const Color borderStrong = Color(0xFFD8DDE8);
  static const Color borderMuted = Color(0xFFE7E8EF);
  static const Color borderSubtle = Color(0xFFE4E5EC);
  static const Color borderSoft = Color(0xFFE1E5EF);
  static const Color borderAlt = Color(0xFFCFD6E4);
  static const Color borderLight = Color(0xFFDBE3EE);
  static const Color borderLight2 = Color(0xFFD3DEEA);
  static const Color borderLight3 = Color(0xFFD9E2EE);

  static const Color primary = Color(0xFF0F1219);
  static const Color primarySoft = Color(0xFF1B2330);

  static const Color positive = Color(0xFF1F8C77);
  static const Color negative = Color(0xFFB84D4D);

  static const Color hintText = textMuted;

  static const Color shadowSoft = Color(0x290F1219);
  static const Color shadowMedium = Color(0x14121C2B);
  static const Color shadowStrong = Color(0x240F1219);

  static const Color surfaceSoft = surfaceSubtle;
}

class AppRadii {
  const AppRadii._();

  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 14;
  static const double xxl = 16;
  static const double xxxl = 24;
  static const double pill = 999;
}

class AppSizes {
  const AppSizes._();

  static const double buttonHeight = 52;
}

class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle bodyMd = TextStyle(color: AppColors.text, fontSize: 14);
  static const TextStyle bodyLg = TextStyle(color: AppColors.text, fontSize: 16);

  static const TextStyle titleLg = TextStyle(
    color: AppColors.text,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleMd = TextStyle(
    color: AppColors.text,
    fontWeight: FontWeight.w600,
  );
}

class AppShadows {
  const AppShadows._();

  static const BoxShadow panel = BoxShadow(
    color: AppColors.shadowSoft,
    blurRadius: 18,
    offset: Offset(0, 8),
  );
}

class AppTheme {
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color surfaceMuted = AppColors.surfaceMuted;
  static const Color surfaceSoft = AppColors.surfaceSoft;
  static const Color text = AppColors.text;
  static const Color textMuted = AppColors.textMuted;
  static const Color border = AppColors.border;
  static const Color borderSoft = AppColors.borderSoft;
  static const Color primary = AppColors.primary;
  static const Color primarySoft = AppColors.primarySoft;
  static const Color positive = AppColors.positive;
  static const Color negative = AppColors.negative;

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surface,
    ).copyWith(
      primary: primary,
      secondary: positive,
      surface: surface,
      onSurface: text,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: const TextTheme(
        bodyMedium: AppTextStyles.bodyMd,
        bodyLarge: AppTextStyles.bodyLg,
        titleLarge: AppTextStyles.titleLg,
        titleMedium: AppTextStyles.titleMd,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.hintText, fontSize: 15),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(color: text, fontWeight: FontWeight.w600),
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            borderSide: const BorderSide(color: border),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          side: const BorderSide(color: border),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          side: const BorderSide(color: borderSoft),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      dividerTheme: const DividerThemeData(color: borderSoft, thickness: 1),
    );
  }
}
