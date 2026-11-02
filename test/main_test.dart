import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/features/splash/presentation/views/location_access_screen.dart';
import 'package:geo_fencing/features/splash/presentation/views/splash_screen.dart';
import 'package:geo_fencing/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          return 3;
        default:
          return null;
      }
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (MethodCall call) async {
      return 1;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geolocatorChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  group('Main App & SplashGate Tests', () {
    testWidgets('OfficeCheckApp builds MaterialApp with Theme and SplashGate', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: OfficeCheckApp(),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(SplashGate), findsOneWidget);
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('SplashGate navigates from SplashScreen to LocationAccessScreen after timer fires', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: OfficeCheckApp(),
        ),
      );

      // Initially shows SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(LocationAccessScreen), findsNothing);

      // Fast-forward 2 seconds for splash gate timer
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(LocationAccessScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });
  });
}
