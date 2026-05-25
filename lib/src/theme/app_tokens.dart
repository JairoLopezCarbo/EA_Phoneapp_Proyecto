import 'package:flutter/material.dart';

/// Tokens compartidos del diseño (colores, radios, tipografías base, etc.).
///
/// Regla práctica:
/// - Aquí va lo genérico y reutilizable en varias pantallas/componentes.
/// - Lo específico (p.ej. un color de un badge puntual) queda en su widget.
class AppColors {
  const AppColors._();

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF6F6F6);
  static const Color surfaceSoft = Color(0xFFFAFAFA);

  static const Color text = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color border = Color(0xFFE5E5E5);
  static const Color borderSoft = Color(0xFFEEEEEE);

  static const Color primary = Color(0xFF1A1A1A);
  static const Color primarySoft = Color(0xFF333333);

  static const Color positive = Color(0xFF1F8C77);
  static const Color negative = Color(0xFFB84D4D);

  static const Color hintText = Color(0xFFAAAAAA);

  /// Sombra suave usada en paneles/menús.
  static const Color shadowSoft = Color(0x0F000000);
}

class AppRadii {
  const AppRadii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 18;

  /// Valor muy grande para crear “pill”.
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
    blurRadius: 20,
    offset: Offset(0, 8),
  );
}
