import 'package:flutter/material.dart';

/// Centralized application dimensions, radius, gaps, and sizes.
/// Reusable by calling [Sizes.p16], [Sizes.buttonHeight], [Sizes.radius16], etc.
class Sizes {
  Sizes._();

  // Spacing & Padding Constants
  static const double p2 = 2.0;
  static const double p4 = 4.0;
  static const double p6 = 6.0;
  static const double p8 = 8.0;
  static const double p10 = 10.0;
  static const double p12 = 12.0;
  static const double p13 = 13.0;
  static const double p14 = 14.0;
  static const double p15 = 15.0;
  static const double p16 = 16.0;
  static const double p18 = 18.0;
  static const double p20 = 20.0;
  static const double p22 = 22.0;
  static const double p24 = 24.0;
  static const double p26 = 26.0;
  static const double p28 = 28.0;
  static const double p30 = 30.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p42 = 42.0;
  static const double p48 = 48.0;
  static const double p54 = 54.0;

  // Border Radii Values
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r13 = 13.0;
  static const double r14 = 14.0;
  static const double r16 = 16.0;
  static const double r18 = 18.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double r28 = 28.0;
  static const double r30 = 30.0;
  static const double rFull = 999.0;

  // BorderRadius Helpers
  static final BorderRadius radius8 = BorderRadius.circular(r8);
  static final BorderRadius radius12 = BorderRadius.circular(r12);
  static final BorderRadius radius13 = BorderRadius.circular(r13);
  static final BorderRadius radius14 = BorderRadius.circular(r14);
  static final BorderRadius radius16 = BorderRadius.circular(r16);
  static final BorderRadius radius18 = BorderRadius.circular(r18);
  static final BorderRadius radius20 = BorderRadius.circular(r20);
  static final BorderRadius radius24 = BorderRadius.circular(r24);
  static final BorderRadius radius28 = BorderRadius.circular(r28);
  static final BorderRadius radius30 = BorderRadius.circular(r30);
  static const BorderRadius radiusBottomSheet = BorderRadius.vertical(top: Radius.circular(r28));

  // Icon Sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconHero = 54.0;
  static const double iconGiant = 64.0;

  // Button Heights & Dimensions
  static const double buttonHeight = 54.0;
  static const double maxContentWidth = 420.0;

  // Horizontal Spacers (Gaps)
  static const Widget gapW4 = SizedBox(width: p4);
  static const Widget gapW8 = SizedBox(width: p8);
  static const Widget gapW10 = SizedBox(width: p10);
  static const Widget gapW12 = SizedBox(width: p12);
  static const Widget gapW13 = SizedBox(width: p13);
  static const Widget gapW16 = SizedBox(width: p16);
  static const Widget gapW20 = SizedBox(width: p20);
  static const Widget gapW24 = SizedBox(width: p24);

  // Vertical Spacers (Gaps)
  static const Widget gapH4 = SizedBox(height: p4);
  static const Widget gapH8 = SizedBox(height: p8);
  static const Widget gapH10 = SizedBox(height: p10);
  static const Widget gapH12 = SizedBox(height: p12);
  static const Widget gapH14 = SizedBox(height: p14);
  static const Widget gapH16 = SizedBox(height: p16);
  static const Widget gapH18 = SizedBox(height: p18);
  static const Widget gapH20 = SizedBox(height: p20);
  static const Widget gapH24 = SizedBox(height: p24);
  static const Widget gapH26 = SizedBox(height: p26);
  static const Widget gapH28 = SizedBox(height: p28);
  static const Widget gapH30 = SizedBox(height: p30);
  static const Widget gapH32 = SizedBox(height: p32);
  static const Widget gapH40 = SizedBox(height: p40);
  static const Widget gapH42 = SizedBox(height: p42);
}

typedef AppSizes = Sizes;
