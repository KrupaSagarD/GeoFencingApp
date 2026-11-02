import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/core/contants/constants.dart';

void main() {
  group('AppColors', () {
    test('defines expected theme colors', () {
      expect(AppColors.blue, const Color(0xFF2563EB));
      expect(AppColors.blueDark, const Color(0xFF1D4ED8));
      expect(AppColors.background, const Color(0xFFF6F8FC));
      expect(AppColors.panel, const Color(0xFFFFFFFF));
      expect(AppColors.panelAlt, const Color(0xFFEBF1FA));
      expect(AppColors.darkCard, const Color(0xFFEDF2F9));
      expect(AppColors.white, Colors.white);
      expect(AppColors.textPrimary, const Color(0xFF0F172A));
      expect(AppColors.textSecondary, const Color(0xFF334155));
      expect(AppColors.success, const Color(0xFF16A34A));
      expect(AppColors.error, const Color(0xFFDC2626));
      expect(AppColors.cyan, const Color(0xFF0284C7));
    });
  });

  group('Sizes', () {
    test('defines correct spacing and dimension constants', () {
      expect(Sizes.p2, 2.0);
      expect(Sizes.p16, 16.0);
      expect(Sizes.buttonHeight, 54.0);
      expect(Sizes.iconMd, 20.0);
      expect(Sizes.iconGiant, 64.0);
      expect(Sizes.radius16, BorderRadius.circular(16.0));
      expect(Sizes.gapW10, isA<SizedBox>());
      expect(Sizes.gapH16, isA<SizedBox>());
    });
  });

  group('AppPaddings', () {
    test('defines standard padding configurations', () {
      expect(AppPaddings.card, const EdgeInsets.all(15.0));
      expect(AppPaddings.screen, const EdgeInsets.symmetric(horizontal: 26, vertical: 24));
      expect(AppPaddings.alert, const EdgeInsets.all(14.0));
      expect(AppPaddings.screenWide, const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0));
    });
  });

  group('TextStyles', () {
    test('defines core text styles with expected typography attributes', () {
      expect(TextStyles.heroLarge.fontSize, 35.0);
      expect(TextStyles.heroLarge.fontWeight, FontWeight.w700);
      expect(TextStyles.button.fontSize, 15.0);
      expect(TextStyles.button.fontWeight, FontWeight.w600);
      expect(TextStyles.bodySmall.fontSize, 11.0);
      expect(TextStyles.timeDisplay.fontSize, 18.0);
      expect(TextStyles.cyanLink.color, AppColors.blue);
    });
  });

  group('Decorations', () {
    test('concentricCircle decoration returns valid box decoration', () {
      final dec = Decorations.concentricCircle(borderColor: AppColors.error, borderWidth: 2.0);
      expect(dec.shape, BoxShape.circle);
      expect(dec.border, isNotNull);
    });

    test('panelCard returns box decoration with border and shadow', () {
      final dec = Decorations.panelCard();
      expect(dec.color, AppColors.panel);
      expect(dec.borderRadius, Sizes.radius18);
      expect(dec.boxShadow, isNotEmpty);
    });

    test('statusPill and messageCard return themed decorations', () {
      final pillDec = Decorations.statusPill(Colors.green);
      expect(pillDec.borderRadius, Sizes.radius20);

      final msgDec = Decorations.messageCard(Colors.amber);
      expect(msgDec.borderRadius, Sizes.radius14);

      expect(Decorations.errorBox.color, AppColors.errorBackground);
      expect(Decorations.floatingStatusBadge.shape, BoxShape.circle);
      expect(Decorations.roundedHeroIcon.borderRadius, Sizes.radius30);
    });
  });
}
