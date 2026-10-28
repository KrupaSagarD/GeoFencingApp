import 'package:flutter/material.dart';
import 'colors.dart';

/// Centralized application typography and text styles for Light Theme.
class TextStyles {
  TextStyles._();

  /// Splash / Hero Large Title: 35pt bold
  static const TextStyle heroLarge = TextStyle(
    fontSize: 35,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    color: AppColors.textPrimary,
  );

  /// Onboarding Screen Title: 30pt bold
  static const TextStyle headline = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.7,
    color: AppColors.textPrimary,
  );

  /// Large Metric / Distance Counter: 36pt bold
  static const TextStyle metricLarge = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
  );

  /// Screen Headline 29pt: 29pt bold
  static const TextStyle headline29 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 29,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );

  /// Bottom Sheet / Section Title: 22pt bold
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// App Bar Title: 20pt bold
  static const TextStyle appBarTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  /// Time display: 18pt bold
  static const TextStyle timeDisplay = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  /// Section Subtitle / Header: 17pt semi-bold
  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  /// Row / Item Title: 14pt semi-bold
  static const TextStyle itemTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Body regular (large): 15pt
  static const TextStyle bodyLarge = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 15,
    letterSpacing: 0.3,
    height: 1.6,
  );

  /// Body regular (medium): 14pt
  static const TextStyle bodyMedium = TextStyle(
    color: AppColors.muted,
    fontSize: 14,
    height: 1.6,
  );

  /// Body small / descriptions: 12pt
  static const TextStyle bodySmall12 = TextStyle(
    color: AppColors.muted,
    fontSize: 12,
    height: 1.55,
  );

  /// Body small / descriptions: 11pt
  static const TextStyle bodySmall = TextStyle(
    color: AppColors.muted,
    fontSize: 11,
    height: 1.45,
  );

  /// Button text: 15pt semi-bold
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  /// Small brand badge / category header: 11pt w600
  static const TextStyle brandLabel = TextStyle(
    color: AppColors.textMuted,
    fontSize: 11,
    letterSpacing: 3,
    fontWeight: FontWeight.w600,
  );

  /// Category Header / Section Tag: 11pt bold
  static const TextStyle sectionHeader = TextStyle(
    color: AppColors.muted,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.3,
  );

  /// Cyan / Primary Action Link: 14pt
  static const TextStyle cyanLink = TextStyle(
    color: AppColors.blue,
    fontWeight: FontWeight.w600,
  );

  /// Bottom banner / overline: 9pt w600
  static const TextStyle overline = TextStyle(
    color: AppColors.textSubtle,
    fontSize: 9,
    letterSpacing: 1.3,
    fontWeight: FontWeight.w600,
  );

  /// Overline 10pt with letter spacing
  static const TextStyle overline10 = TextStyle(
    color: AppColors.textSubtle,
    fontSize: 10,
    letterSpacing: 1.1,
    height: 1.6,
  );
}

typedef AppTextStyles = TextStyles;
