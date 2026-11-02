import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/core/localization/app_locale.dart';
import 'package:geo_fencing/features/splash/presentation/views/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const permissionChannel = MethodChannel('flutter.baseflow.com/permissions/methods');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (MethodCall call) async {
      if (call.method == 'checkPermissionStatus') {
        return 1; // Granted
      }
      if (call.method == 'requestPermissions') {
        return {17: 1};
      }
      if (call.method == 'openAppSettings') {
        return true;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  group('SettingsScreen Widget Tests', () {
    testWidgets('renders settings title, preferences, and permissions sections', (tester) async {
      await tester.pumpWidget(
        createLocalizedWidget(child: const SettingsScreen()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('App permissions'), findsOneWidget);
    });

    testWidgets('tapping language card opens modal sheet and changing language updates AppLocale', (tester) async {
      await tester.pumpWidget(
        createLocalizedWidget(child: const SettingsScreen()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Language card
      final languageCard = find.text('Language');
      expect(languageCard, findsOneWidget);
      await tester.tap(languageCard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Modal bottom sheet should now be visible with Japanese option
      final jaOption = find.text('日本語');
      expect(jaOption, findsOneWidget);
      await tester.tap(jaOption);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(AppLocale.locale.value, const Locale('ja'));
    });

    testWidgets('notification card displays switch in enabled state when permission is granted', (tester) async {
      await tester.pumpWidget(
        createLocalizedWidget(child: const SettingsScreen()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isTrue);
    });
  });
}
