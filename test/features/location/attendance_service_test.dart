import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/features/location/data/services/attendance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AttendanceService Unit Tests', () {
    final now = DateTime(2026, 11, 2, 17, 30);
    final todayKey = '2026-11-02';

    test('autoCheckout returns false when history is null', () async {
      SharedPreferences.setMockInitialValues({});

      final result = await AttendanceService.autoCheckout(now);
      expect(result, isFalse);
    });

    test('autoCheckout returns false when history is invalid JSON or not a List', () async {
      SharedPreferences.setMockInitialValues({
        AttendanceService.historyKey: '{"invalid": "format"}',
      });

      final result = await AttendanceService.autoCheckout(now);
      expect(result, isFalse);
    });

    test('autoCheckout returns false when no record exists for today', () async {
      final records = [
        {
          'date': '2026-11-01',
          'sessions': [
            {
              'checkInTime': '2026-11-01T09:00:00.000',
              'checkOutTime': '2026-11-01T17:00:00.000',
            }
          ]
        }
      ];

      SharedPreferences.setMockInitialValues({
        AttendanceService.historyKey: jsonEncode(records),
      });

      final result = await AttendanceService.autoCheckout(now);
      expect(result, isFalse);
    });

    test('autoCheckout returns false when today record has no active check-in session', () async {
      final records = [
        {
          'date': todayKey,
          'sessions': [
            {
              'checkInTime': '2026-11-02T09:00:00.000',
              'checkOutTime': '2026-11-02T13:00:00.000',
            }
          ]
        }
      ];

      SharedPreferences.setMockInitialValues({
        AttendanceService.historyKey: jsonEncode(records),
      });

      final result = await AttendanceService.autoCheckout(now);
      expect(result, isFalse);
    });

    test('autoCheckout successfully closes active session, updates preferences, and increments version', () async {
      final records = [
        {
          'date': todayKey,
          'sessions': [
            {
              'checkInTime': '2026-11-02T09:00:00.000',
              'checkOutTime': null,
            }
          ]
        }
      ];

      SharedPreferences.setMockInitialValues({
        AttendanceService.historyKey: jsonEncode(records),
        'officecheck_checked_in': true,
      });

      final initialVersion = AttendanceService.attendanceVersion.value;

      final result = await AttendanceService.autoCheckout(now);
      expect(result, isTrue);

      expect(AttendanceService.attendanceVersion.value, initialVersion + 1);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('officecheck_checked_in'), isFalse);
      expect(prefs.getString('officecheck_check_out_time'), now.toLocal().toIso8601String());

      final updatedRaw = prefs.getString(AttendanceService.historyKey);
      expect(updatedRaw, isNotNull);
      final updatedList = jsonDecode(updatedRaw!) as List;
      final todayRec = updatedList.first as Map;
      final sessions = todayRec['sessions'] as List;
      expect(sessions.first['checkOutTime'], now.toLocal().toIso8601String());
      expect(sessions.first['checkOutType'], 'geofence');
    });

    test('autoCheckout correctly checks out latest active session when multiple sessions exist', () async {
      final records = [
        {
          'date': todayKey,
          'sessions': [
            {
              'checkInTime': '2026-11-02T09:00:00.000',
              'checkOutTime': '2026-11-02T12:00:00.000',
              'checkOutType': 'manual',
            },
            {
              'checkInTime': '2026-11-02T13:00:00.000',
              'checkOutTime': null,
            }
          ]
        }
      ];

      SharedPreferences.setMockInitialValues({
        AttendanceService.historyKey: jsonEncode(records),
      });

      final result = await AttendanceService.autoCheckout(now);
      expect(result, isTrue);

      final prefs = await SharedPreferences.getInstance();
      final updatedList = jsonDecode(prefs.getString(AttendanceService.historyKey)!) as List;
      final sessions = (updatedList.first as Map)['sessions'] as List;
      expect(sessions[0]['checkOutTime'], '2026-11-02T12:00:00.000');
      expect(sessions[1]['checkOutTime'], now.toLocal().toIso8601String());
      expect(sessions[1]['checkOutType'], 'geofence');
    });
  });
}
