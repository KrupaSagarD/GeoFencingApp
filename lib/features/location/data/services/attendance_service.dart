import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/geofence_debug.dart';

/// Centralized attendance persistence service.
///
/// Used by both the foreground [HomeScreen] and the background
/// [BackgroundLocationScreen] geofence exit callback so that the
/// attendance history stored under [historyKey] is always the
/// single source of truth.
class AttendanceService {
  static const String historyKey = 'officecheck_attendance_history';
  static final ValueNotifier<int> attendanceVersion = ValueNotifier(0);


  static String _dateKey(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static Future<bool> autoCheckout(DateTime eventTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Refresh cached values before reading attendance history.
      await prefs.reload();

      final today = _dateKey(eventTime.toLocal());
      final raw = prefs.getString(historyKey);

      debugPrint('Auto checkout date: $today');
      debugPrint('Attendance history exists: ${raw != null}');

      if (raw == null) {
        GeofenceDebug.show(
          'CHECKOUT FAILED: Attendance history not found',
          isError: true,
        );
        return false;
      }

      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        GeofenceDebug.show(
          'CHECKOUT FAILED: Invalid attendance history format',
          isError: true,
        );
        return false;
      }

      final records = decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      Map<String, dynamic>? todayRecord;

      for (final record in records) {
        if (record['date'] == today) {
          todayRecord = record;
          break;
        }
      }

      if (todayRecord == null) {
        GeofenceDebug.show(
          'CHECKOUT FAILED: No attendance record for $today',
          isError: true,
        );
        return false;
      }

      final rawSessions = todayRecord['sessions'];

      final sessions = rawSessions is List
          ? rawSessions
          .whereType<Map>()
          .map((s) => Map<String, dynamic>.from(s))
          .toList()
          : <Map<String, dynamic>>[];

      int? activeIndex;

      for (var i = sessions.length - 1; i >= 0; i--) {
        if (sessions[i]['checkInTime'] != null &&
            sessions[i]['checkOutTime'] == null) {
          activeIndex = i;
          break;
        }
      }

      if (activeIndex == null) {
        GeofenceDebug.show(
          'CHECKOUT FAILED: No active check-in session',
          isError: true,
        );
        return false;
      }

      final checkoutStr = eventTime.toLocal().toIso8601String();

      sessions[activeIndex]['checkOutTime'] = checkoutStr;
      sessions[activeIndex]['checkOutType'] = 'geofence';

      todayRecord['sessions'] = sessions;

      final saved = await prefs.setString(
        historyKey,
        jsonEncode(records),
      );

      if (!saved) {
        GeofenceDebug.show(
          'CHECKOUT FAILED: Could not save attendance history',
          isError: true,
        );
        return false;
      }

      await prefs.setBool('officecheck_checked_in', false);
      await prefs.setString(
        'officecheck_check_out_time',
        checkoutStr,
      );

      attendanceVersion.value++;

      GeofenceDebug.show(
        'CHECKOUT SAVED: ${eventTime.toLocal()}',
      );

      return true;
    } catch (error, stackTrace) {
      debugPrint('AttendanceService.autoCheckout error: $error');
      debugPrintStack(stackTrace: stackTrace);

      GeofenceDebug.show(
        'CHECKOUT ERROR: $error',
        isError: true,
      );

      return false;
    }
  }}
