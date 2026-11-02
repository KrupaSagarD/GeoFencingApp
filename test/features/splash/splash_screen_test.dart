import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/core/contants/reusable_widgets.dart';
import 'package:geo_fencing/features/splash/presentation/views/splash_screen.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('SplashScreen renders branding, illustrations, and loading indicator', (tester) async {
    await tester.pumpWidget(
      createLocalizedWidget(child: const SplashScreen()),
    );

    // Pump to advance TweenAnimationBuilder
    await tester.pump(const Duration(milliseconds: 1100));

    // Verify smart workplace label
    expect(find.text('SMART WORKPLACE'), findsOneWidget);

    // Verify illustration is present
    expect(find.byType(GeofenceConcentricIllustration), findsOneWidget);

    // Verify progress indicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Verify rich text has Office and Check
    expect(find.byType(RichText), findsWidgets);
  });

  testWidgets('SplashScreen renders localized Japanese text when ja locale is passed', (tester) async {
    await tester.pumpWidget(
      createLocalizedWidget(
        child: const SplashScreen(),
        locale: const Locale('ja'),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1100));

    expect(find.text('スマートワークプレイス'), findsOneWidget);
  });
}
