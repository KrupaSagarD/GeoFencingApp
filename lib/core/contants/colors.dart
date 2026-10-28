import 'package:flutter/material.dart';

/// Centralized application colors - Light Theme.
class AppColors {
  AppColors._();

  // Core brand background & surfaces (Light theme)
  static const Color background = Color(0xFFF6F8FC);
  static const Color panel = Color(0xFFFFFFFF);
  static const Color panelAlt = Color(0xFFEBF1FA);
  static const Color darkCard = Color(0xFFEDF2F9);

  // Primary blues & cyans
  static const Color blue = Color(0xFF2563EB); // Vibrant royal blue
  static const Color blueDark = Color(0xFF1D4ED8);
  static const Color blueGradientStart = Color(0xFF3B82F6);
  static const Color blueGradientEnd = Color(0xFF1D4ED8);
  static const Color cyan = Color(0xFF0284C7); // Readable light mode blue/cyan accent

  // Typography / Muted shades
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF334155); // Slate 700
  static const Color muted = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSubtle = Color(0xFF94A3B8); // Slate 400

  // Status colors - Error / Alert
  static const Color error = Color(0xFFDC2626);
  static const Color errorBackground = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);
  static const Color errorText = Color(0xFF991B1B);

  // Status colors - Success
  static const Color success = Color(0xFF16A34A);
  static const Color successBackground = Color(0xFFF0FDF4);
  static const Color successBorder = Color(0xFFBBF7D0);
  static const Color successText = Color(0xFF166534);

  // Border, dividers & shadows
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x0C000000);
  static const Color white = Colors.white;
}
