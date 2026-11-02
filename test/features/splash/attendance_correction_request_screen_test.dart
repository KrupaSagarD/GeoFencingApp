import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/features/splash/presentation/views/attendence_correction_request_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AttendanceCorrectionRequest Model Tests', () {
    test('toJson and fromJson work symmetrically', () {
      const model = AttendanceCorrectionRequest(
        id: '123',
        attendanceDate: '2026-11-02',
        requestedCheckInTime: '2026-11-02T09:00:00.000',
        originalCheckInTime: '2026-11-02T10:15:00.000',
        reason: 'forgot',
        note: 'Forgot my device in car',
        submittedAt: '2026-11-02T18:00:00.000',
        status: 'pending',
        reviewNote: null,
      );

      final jsonMap = model.toJson();
      expect(jsonMap['id'], '123');
      expect(jsonMap['attendanceDate'], '2026-11-02');
      expect(jsonMap['reason'], 'forgot');

      final reconstructed = AttendanceCorrectionRequest.fromJson(jsonMap);
      expect(reconstructed.id, '123');
      expect(reconstructed.attendanceDate, '2026-11-02');
      expect(reconstructed.note, 'Forgot my device in car');
      expect(reconstructed.status, 'pending');
    });
  });

  group('AttendanceCorrectionRequestScreen Widget Tests', () {
    testWidgets('renders screen title, date, time, reason dropdown, and note fields', (tester) async {
      await tester.pumpWidget(
        createLocalizedWidget(child: const AttendanceCorrectionRequestScreen()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Attendance Correction'), findsOneWidget);
      expect(find.text('Attendance date'), findsOneWidget);
      expect(find.text('Requested first check-in time'), findsOneWidget);
      expect(find.text('Reason for correction'), findsOneWidget);
      expect(find.text('Additional note (optional)'), findsOneWidget);
    });

    testWidgets('shows warning when a correction request is already pending for this date', (tester) async {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      SharedPreferences.setMockInitialValues({
        'officecheck_attendance_correction_requests': jsonEncode([
          {
            'id': '999',
            'attendanceDate': dateStr,
            'status': 'pending',
          }
        ]),
      });

      await tester.pumpWidget(
        createLocalizedWidget(child: const AttendanceCorrectionRequestScreen()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Drag to submit button
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final submitBtn = find.text('Submit correction request');
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('A correction request is already pending for this date.'), findsOneWidget);
    });

    testWidgets('successfully submits valid correction request and saves to SharedPreferences', (tester) async {
      await tester.pumpWidget(
        createLocalizedWidget(child: const AttendanceCorrectionRequestScreen()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Drag ListView to reveal the note field and submit button
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Enter text into the note field
      final noteField = find.byType(TextFormField);
      expect(noteField, findsOneWidget);
      await tester.enterText(noteField, 'Traffic caused check-in delay, worked remotely from 9am');
      await tester.pump();

      // Submit
      final submitBtn = find.text('Submit correction request');
      expect(submitBtn, findsOneWidget);
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check AlertDialog
      expect(find.text('Request saved'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify stored in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('officecheck_attendance_correction_requests');
      expect(raw, isNotNull);
      final list = jsonDecode(raw!) as List;
      expect(list, hasLength(1));
      expect(list.first['reason'], 'forgot');
      expect(list.first['status'], 'pending');
    });
  });
}
