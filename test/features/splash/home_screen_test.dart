import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/features/splash/presentation/views/attendence_history_screen.dart';
import 'package:geo_fencing/features/splash/presentation/views/home_screen.dart';
import 'package:geo_fencing/features/splash/presentation/views/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const geolocatorChannel = MethodChannel('flutter.baseflow.com/geolocator');
  const nativeChannel = MethodChannel('com.example.geo_fencing/geofence');
  const notificationChannel = MethodChannel('dexterous.com/flutter/local_notifications');

  final mockPosition = <String, dynamic>{
    'latitude': 12.9328497,
    'longitude': 77.5400525,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'altitude': 0.0,
    'accuracy': 5.0,
    'heading': 0.0,
    'floor': null,
    'speed': 0.0,
    'speed_accuracy': 0.0,
    'is_mocked': false,
  };

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geolocatorChannel, (MethodCall call) async {
      switch (call.method) {
        case 'isLocationServiceEnabled':
          return true;
        case 'checkPermission':
          return 3; // LocationPermission.always
        case 'requestPermission':
          return 3;
        case 'getLastKnownPosition':
          return mockPosition;
        case 'getCurrentPosition':
          return mockPosition;
        default:
          return null;
      }
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(nativeChannel, (MethodCall call) async {
      return true;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationChannel, (MethodCall call) async {
      return true;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geolocatorChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(nativeChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationChannel, null);
  });

  group('HomeScreen Widget Tests', () {
    testWidgets('renders office header, distance indicator, and action buttons', (tester) async {
      await tester.pumpWidget(
        createLocalizedWidget(child: const HomeScreen()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('OfficeCheck'), findsOneWidget);
      expect(find.text('OFFICE PROXIMITY'), findsOneWidget);
      expect(find.text('Check In'), findsOneWidget);
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    });

    testWidgets('tapping settings icon navigates to SettingsScreen', (tester) async {
      await tester.pumpWidget(
        createLocalizedWidget(child: const HomeScreen()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final settingsBtn = find.byIcon(Icons.settings_rounded);
      expect(settingsBtn, findsOneWidget);
      await tester.tap(settingsBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('tapping View Attendance History button navigates to AttendanceHistoryScreen', (tester) async {
      await tester.pumpWidget(
        createLocalizedWidget(child: const HomeScreen()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Scroll to history button
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final historyBtn = find.text('View Attendance History');
      expect(historyBtn, findsOneWidget);
      await tester.tap(historyBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(AttendanceHistoryScreen), findsOneWidget);
    });

    testWidgets('tapping Check In button toggles check-in state to Check Out', (tester) async {
      await tester.pumpWidget(
        createLocalizedWidget(child: const HomeScreen()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final checkInBtn = find.text('Check In');
      expect(checkInBtn, findsOneWidget);

      await tester.tap(checkInBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Check Out'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('officecheck_checked_in'), isTrue);
    });
  });
}
