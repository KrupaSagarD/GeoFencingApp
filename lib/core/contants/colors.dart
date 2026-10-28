import 'package:flutter/material.dart';

/// Centralized application colors.
/// Can be accessed using [AppColors.background] or [Colors.background] where imported.
class AppColors {
  AppColors._();

  // Core brand background & surfaces
  static const Color background = Color(0xFF071426);
  static const Color panel = Color(0xFF10223A);
  static const Color panelAlt = Color(0xFF102B43);
  static const Color darkCard = Color(0xFF0D1D30);

  // Primary blues & cyans
  static const Color blue = Color(0xFF3987FF);
  static const Color blueDark = Color(0xFF1450C8);
  static const Color blueGradientStart = Color(0xFF347FFF);
  static const Color blueGradientEnd = Color(0xFF164BC0);
  static const Color cyan = Color(0xFF54E0E8);

  // Typography / Muted shades
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB5C5D9);
  static const Color muted = Color(0xFF9BB0C9);
  static const Color textMuted = Color(0xFF9BB3CE);
  static const Color textSubtle = Color(0xFF7188A5);

  // Status colors - Error / Alert
  static const Color error = Color(0xFFEF4444);
  static const Color errorBackground = Color(0xFF451F2B);
  static const Color errorBorder = Color(0xFF8E3D4B);
  static const Color errorText = Color(0xFFFFC3CC);

  // Status colors - Success
  static const Color success = Color(0xFF22C55E);
  static const Color successBackground = Color(0xFF1F422E);
  static const Color successBorder = Color(0xFF2F7D47);
  static const Color successText = Color(0xFFB4F4C9);

  // Border & divider
  static const Color borderSubtle = Color(0x1AFFFFFF);
  static const Color white = Colors.white;
}
