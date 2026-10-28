import 'package:flutter/material.dart';

/// Centralized application padding constants and EdgeInsets helpers.
class AppPaddings {
  AppPaddings._();

  // Screen level paddings
  static const EdgeInsets screen = EdgeInsets.symmetric(
    horizontal: 26,
    vertical: 24,
  );

  static const EdgeInsets screenWide = EdgeInsets.symmetric(
    horizontal: 28,
    vertical: 20,
  );

  // Card & Container paddings
  static const EdgeInsets card = EdgeInsets.all(15);
  static const EdgeInsets cardLarge = EdgeInsets.all(24);
  static const EdgeInsets cardSmall = EdgeInsets.all(12);
  static const EdgeInsets alert = EdgeInsets.all(14);
  static const EdgeInsets bottomSheet = EdgeInsets.all(24);

  // Common Symmetric Paddings
  static const EdgeInsets h26 = EdgeInsets.symmetric(horizontal: 26);
  static const EdgeInsets h28 = EdgeInsets.symmetric(horizontal: 28);
  static const EdgeInsets v20 = EdgeInsets.symmetric(vertical: 20);
  static const EdgeInsets v24 = EdgeInsets.symmetric(vertical: 24);

  // All-around paddings
  static const EdgeInsets all8 = EdgeInsets.all(8);
  static const EdgeInsets all9 = EdgeInsets.all(9);
  static const EdgeInsets all12 = EdgeInsets.all(12);
  static const EdgeInsets all14 = EdgeInsets.all(14);
  static const EdgeInsets all15 = EdgeInsets.all(15);
  static const EdgeInsets all16 = EdgeInsets.all(16);
  static const EdgeInsets all20 = EdgeInsets.all(20);
  static const EdgeInsets all24 = EdgeInsets.all(24);
}

typedef Paddings = AppPaddings;
