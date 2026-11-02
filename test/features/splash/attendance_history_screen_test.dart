import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/features/splash/presentation/views/attendence_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const historyKey = 'officecheck_attendance_history';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AttendanceHistoryScreen Widget Tests', () {
    testWidgets('renders empty state when no attendance records exist', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        createLocalizedWidget(child: const AttendanceHistoryScreen()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Attendance History'), findsOneWidget);
      expect(find.text('No attendance records for this period'), findsOneWidget);
    });

    testWidgets('renders records and allows switching between Daily, Weekly, and Monthly periods', (tester) async {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final sampleRecords = [
        {
          'date': todayStr,
          'sessions': [
            {
              'checkInTime': '${todayStr}T09:00:00.000',
              'checkOutTime': '${todayStr}T17:30:00.000',
              'checkOutType': 'manual',
            }
          ]
        }
      ];

      SharedPreferences.setMockInitialValues({
        historyKey: jsonEncode(sampleRecords),
      });

      await tester.pumpWidget(
        createLocalizedWidget(child: const AttendanceHistoryScreen()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);

      // Verify stats and session card
      expect(find.text('Total worked'), findsWidgets);
      expect(find.text('Days attended'), findsOneWidget);

      // Switch to Weekly period
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      expect(find.text('Total worked'), findsWidgets);

      // Switch to Monthly period
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      expect(find.text('Total worked'), findsWidgets);
    });
  });
}
