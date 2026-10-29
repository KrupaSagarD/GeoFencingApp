import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized attendance persistence service.
///
/// Used by both the foreground [HomeScreen] and the background
/// [BackgroundLocationScreen] geofence exit callback so that the
/// attendance history stored under [historyKey] is always the
/// single source of truth.
class AttendanceService {
  static const String historyKey = 'officecheck_attendance_history';

  static String _dateKey(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Automatically checks out the last active session at [eventTime] and
  /// marks the checkout type as **'geofence'**.
  ///
  /// Safe to call from background isolates because it only uses
  /// [SharedPreferences] and JSON (no Flutter widgets).
  static Future<bool> autoCheckout(DateTime eventTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _dateKey(eventTime.toLocal());

      final raw = prefs.getString(historyKey);
      final List<Map<String, dynamic>> records = [];

      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          records.addAll(
            decoded
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e)),
          );
        }
      }


      Map<String, dynamic>? todayRecord;
      for (final r in records) {
        if (r['date'] == today) {
          todayRecord = r;
          break;
        }
      }

      if (todayRecord == null) {
        debugPrint('AttendanceService.autoCheckout: no record for $today');
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
        debugPrint('AttendanceService.autoCheckout: no active session to close');
        return false;
      }

      final checkoutStr = eventTime.toLocal().toIso8601String();

      sessions[activeIndex]['checkOutTime'] = checkoutStr;
      sessions[activeIndex]['checkOutType'] = 'geofence';

      todayRecord['sessions'] = sessions;

      await prefs.setString(historyKey, jsonEncode(records));

      await prefs.setBool('officecheck_checked_in', false);
      await prefs.setString('officecheck_check_out_time', checkoutStr);

      debugPrint(
        'AttendanceService.autoCheckout: session[$activeIndex] '
        'closed at $checkoutStr (geofence exit)',
      );
      return true;
    } catch (e, st) {
      debugPrint('AttendanceService.autoCheckout error: $e');
      debugPrintStack(stackTrace: st);
      return false;
    }
  }
}
