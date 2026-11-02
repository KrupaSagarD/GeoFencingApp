import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/core/contants/reusable_widgets.dart';

void main() {
  group('AppGlowCircle Widget Tests', () {
    testWidgets('renders Container with given size and radial gradient', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppGlowCircle(size: 150, color: Colors.blue),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      expect(container.constraints?.maxWidth, 150);
      expect(container.constraints?.maxHeight, 150);
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.gradient, isA<RadialGradient>());
    });
  });

  group('AppPrimaryButton Widget Tests', () {
    testWidgets('renders text and responds to tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPrimaryButton(
              text: 'Click Me',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      expect(tapped, isTrue);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPrimaryButton(
              text: 'With Icon',
              icon: Icons.check,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator and disables tap when isLoading is true', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPrimaryButton(
              text: 'Loading Button',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);

      await tester.tap(find.byType(FilledButton));
      expect(tapped, isFalse);
    });
  });

  group('AppErrorBanner Widget Tests', () {
    testWidgets('renders error message correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorBanner(message: 'Something went wrong'),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });

  group('GeofenceConcentricIllustration Widget Tests', () {
    testWidgets('renders concentric circles and icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GeofenceConcentricIllustration(),
          ),
        ),
      );

      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
      expect(find.byIcon(Icons.verified_user_rounded), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(GeofenceConcentricIllustration),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });
  });

  group('PermissionHeroIllustration Widget Tests', () {
    testWidgets('renders center and badge icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PermissionHeroIllustration(
              centerIcon: Icons.my_location,
              badgeIcon: Icons.check,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('PermissionItemRow Widget Tests', () {
    testWidgets('renders row with granted state (check_circle)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PermissionItemRow(
              icon: Icons.location_on,
              title: 'Location Access',
              subtitle: 'Needed to detect workplace',
              isGranted: true,
            ),
          ),
        ),
      );

      expect(find.text('Location Access'), findsOneWidget);
      expect(find.text('Needed to detect workplace'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('renders row with ungranted state (arrow_forward_ios_rounded)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PermissionItemRow(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Get alerts on exit',
              isGranted: false,
            ),
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
    });

    testWidgets('renders custom trailingText when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PermissionItemRow(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Alerts',
              trailingText: 'Enabled',
              isGranted: true,
            ),
          ),
        ),
      );

      expect(find.text('Enabled'), findsOneWidget);
    });
  });

  group('StatusPill Widget Tests', () {
    testWidgets('renders pill with label and dot indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(text: 'ACTIVE', color: Colors.green),
          ),
        ),
      );

      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
    });
  });

  group('AttendanceTimeCard Widget Tests', () {
    testWidgets('renders title, time, and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AttendanceTimeCard(
              title: 'Check-In',
              time: '09:15 AM',
              icon: Icons.login_rounded,
            ),
          ),
        ),
      );

      expect(find.text('Check-In'), findsOneWidget);
      expect(find.text('09:15 AM'), findsOneWidget);
      expect(find.byIcon(Icons.login_rounded), findsOneWidget);
    });
  });

  group('FeedbackMessageCard Widget Tests', () {
    testWidgets('renders message with warning styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedbackMessageCard(
              icon: Icons.warning_amber_rounded,
              message: 'You are currently outside the geofence',
              isWarning: true,
            ),
          ),
        ),
      );

      expect(find.text('You are currently outside the geofence'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('renders message with normal info styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedbackMessageCard(
              icon: Icons.info_outline,
              message: 'Inside workplace radius',
              isWarning: false,
            ),
          ),
        ),
      );

      expect(find.text('Inside workplace radius'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });

  group('SessionTimelineCard Widget Tests', () {
    testWidgets('renders completed session timeline card with duration and check-in/out times', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SessionTimelineCard(
              sessionNumber: 1,
              checkInFormatted: '09:00 AM',
              checkOutFormatted: '05:30 PM',
              durationFormatted: '8h 30m',
              isCompleted: true,
              isAutoGeofence: true,
            ),
          ),
        ),
      );

      expect(find.text('SESSION 1'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('09:00 AM'), findsOneWidget);
      expect(find.text('05:30 PM'), findsOneWidget);
      expect(find.text('Duration: 8h 30m'), findsOneWidget);
      expect(find.text('Geofence Exit'), findsOneWidget);
      expect(find.byIcon(Icons.login_rounded), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });

    testWidgets('renders active now session timeline card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SessionTimelineCard(
              sessionNumber: 2,
              checkInFormatted: '06:00 PM',
              checkOutFormatted: '--:--',
              durationFormatted: '1h 15m',
              isCompleted: false,
              isAutoGeofence: false,
            ),
          ),
        ),
      );

      expect(find.text('SESSION 2'), findsOneWidget);
      expect(find.text('Active Now'), findsOneWidget);
      expect(find.text('06:00 PM'), findsOneWidget);
      expect(find.text('--:--'), findsOneWidget);
      expect(find.text('Duration: 1h 15m'), findsOneWidget);
      expect(find.text('Geofence Exit'), findsNothing);
    });
  });
}
