import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/core/localization/app_locale.dart';
import 'package:geo_fencing/features/splash/presentation/views/location_access_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const geolocatorChannel = MethodChannel('flutter.baseflow.com/geolocator');
  const permissionChannel = MethodChannel('flutter.baseflow.com/permissions/methods');

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geolocatorChannel, (MethodCall call) async {
      switch (call.method) {
        case 'isLocationServiceEnabled':
          return true;
        case 'checkPermission':
          return 3; // LocationPermission.always (0: denied, 1: deniedForever, 2: whileInUse, 3: always)
        case 'requestPermission':
          return 3;
        default:
          return null;
      }
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (MethodCall call) async {
      switch (call.method) {
        case 'checkPermissionStatus':
          return 1; // PermissionStatus.granted
        case 'requestPermissions':
          return {17: 1};
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geolocatorChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  group('LocationAccessScreen Widget Tests', () {
    testWidgets('renders header, permission cards, and language dropdown', (tester) async {
      await tester.pumpWidget(
        createLocalizedWidget(child: const LocationAccessScreen()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Set up your location'), findsOneWidget);
      expect(find.text('Device and foreground location'), findsOneWidget);
      expect(find.text('Background location'), findsOneWidget);
      expect(find.text('Continue to OfficeCheck'), findsOneWidget);
    });

    testWidgets('changing language selector on LocationAccessScreen updates locale', (tester) async {
      await tester.pumpWidget(
        createLocalizedWidget(child: const LocationAccessScreen()),
      );

      await tester.pumpAndSettle();

      final dropdown = find.byType(DropdownButton<String>);
      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final jaOption = find.text('日本語').last;
      await tester.tap(jaOption);
      await tester.pumpAndSettle();

      expect(AppLocale.locale.value, const Locale('ja'));
    });

    testWidgets('disables continue button when permissions are denied', (tester) async {
      // Set geolocator to return denied (0)
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(geolocatorChannel, (MethodCall call) async {
        switch (call.method) {
          case 'isLocationServiceEnabled':
            return false;
          case 'checkPermission':
            return 0; // denied
          default:
            return null;
        }
      });

      await tester.pumpWidget(
        createLocalizedWidget(child: const LocationAccessScreen()),
      );

      await tester.pumpAndSettle();

      final continueButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(continueButton.onPressed, isNull);
    });
  });
}
