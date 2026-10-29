
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geo_fencing/features/splash/presentation/views/settings_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/contants/constants.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'attendence_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  static const double _geofenceRadiusMeters = 100;
  static const double officeLatitude = 12.9328497;
  static const double officeLongitude = 77.5400525;

  static const String _historyKey = 'officecheck_attendance_history';

  Position? _position;
  StreamSubscription<Position>? _positionStreamSubscription;

  bool _isInitializing = true;
  bool _isLoadingLocation = false;
  bool _isSubmittingAttendance = false;
  bool _isCheckedIn = false;

  Timer? _workHoursTimer;

  String? _locationMessage;

  List<Map<String, dynamic>> _todaySessions = [];

  bool get _officeConfigured =>
      officeLatitude != 0 && officeLongitude != 0;

  double? get _distanceMeters {
    final position = _position;
    if (position == null || !_officeConfigured) return null;

    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      officeLatitude,
      officeLongitude,
    );
  }

  void _openAttendanceHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AttendanceHistoryScreen(),
      ),
    );
  }

  bool get _isInsideOffice {
    final distance = _distanceMeters;
    return distance != null && distance <= _geofenceRadiusMeters;
  }

  DateTime? _parseTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  Duration get _totalDuration {
    var total = Duration.zero;
    final now = DateTime.now();

    for (final session in _todaySessions) {
      final checkIn = _parseTime(session['checkInTime']);
      final checkOut = _parseTime(session['checkOutTime']);

      if (checkIn == null) continue;

      final end = checkOut ?? now;

      if (end.isAfter(checkIn)) {
        total += end.difference(checkIn);
      }
    }

    return total;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initializeHome());
    _startLiveLocationUpdates();
    _workHoursTimer = Timer.periodic(
      const Duration(minutes: 1),
          (_) {
        if (mounted && _isCheckedIn) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _workHoursTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshAfterResume());
      _startLiveLocationUpdates();
    } else if (state == AppLifecycleState.paused) {
      _positionStreamSubscription?.cancel();
    }
  }

  void _startLiveLocationUpdates() {
    _positionStreamSubscription?.cancel();
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        if (!mounted || position.isMocked) return;
        setState(() {
          _position = position;
          _locationMessage = null;
          _isLoadingLocation = false;
        });
      },
      onError: (dynamic error) {
        debugPrint('Location stream update error: $error');
      },
    );
  }

  Future<void> _initializeHome() async {
    try {
      await Future.wait([
        _loadAttendance(),
        _refreshLocation(),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _refreshAfterResume() async {
    await _loadAttendance();
    if (!mounted) return;

    await _refreshLocation();
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> _loadAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _dateKey(DateTime.now());

      final rawHistory = prefs.getString(_historyKey);
      final List<Map<String, dynamic>> records = [];

      if (rawHistory != null) {
        final decoded = jsonDecode(rawHistory);

        if (decoded is List) {
          records.addAll(
            decoded
                .whereType<Map>()
                .map((record) => Map<String, dynamic>.from(record)),
          );
        }
      }

      Map<String, dynamic>? todayRecord;

      for (final record in records) {
        if (record['date'] == today) {
          todayRecord = record;
          break;
        }
      }

      if (todayRecord == null) {
        todayRecord = {
          'date': today,
          'sessions': <Map<String, dynamic>>[],
        };
        records.add(todayRecord);
      }

      final rawSessions = todayRecord['sessions'];

      final sessions = rawSessions is List
          ? rawSessions
          .whereType<Map>()
          .map((session) => Map<String, dynamic>.from(session))
          .toList()
          : <Map<String, dynamic>>[];

      if (sessions.isEmpty &&
          prefs.getString('officecheck_date') == today) {
        final legacyCheckIn =
        prefs.getString('officecheck_check_in_time');
        final legacyCheckOut =
        prefs.getString('officecheck_check_out_time');

        if (legacyCheckIn != null) {
          sessions.add({
            'checkInTime': legacyCheckIn,
            'checkOutTime': legacyCheckOut,
            'checkOutType':
            legacyCheckOut == null ? null : 'manual',
          });
        }
      }

      todayRecord['sessions'] = sessions;

      // Recover the actual state from attendance history.
      final activeSessions = sessions.where(
            (session) =>
        session['checkInTime'] != null &&
            session['checkOutTime'] == null,
      ).toList();

      final active = activeSessions.isEmpty
          ? null
          : activeSessions.last;

      final latestSession =
      sessions.isEmpty ? null : sessions.last;

      final checkInValue =
          active?['checkInTime'] ?? latestSession?['checkInTime'];

      final checkOutValue = active != null
          ? null
          : latestSession?['checkOutTime'];

      // Keep legacy preferences synchronized for other screens.
      await prefs.setString('officecheck_date', today);
      await prefs.setBool(
        'officecheck_checked_in',
        active != null,
      );

      if (checkInValue != null) {
        await prefs.setString(
          'officecheck_check_in_time',
          checkInValue.toString(),
        );
      } else {
        await prefs.remove('officecheck_check_in_time');
      }

      if (checkOutValue != null) {
        await prefs.setString(
          'officecheck_check_out_time',
          checkOutValue.toString(),
        );
      } else {
        await prefs.remove('officecheck_check_out_time');
      }

      await prefs.setString(_historyKey, jsonEncode(records));

      if (!mounted) return;

      setState(() {
        _todaySessions = sessions;
        _isCheckedIn = active != null;
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to load attendance: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<Position?> _getFreshPosition() async {
    final l10n = AppLocalizations.of(context);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(l10n.turnOnLocationServices);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception(l10n.locationPermissionRequired);
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(l10n.locationPermissionBlocked);
    }

    // Try last known position first for quick rendering without delay
    Position? pos = await Geolocator.getLastKnownPosition();
    if (pos != null && !pos.isMocked) {
      final lastKnownAge = DateTime.now().difference(pos.timestamp).abs();
      if (lastKnownAge <= const Duration(minutes: 5)) {
        // Return recent cached location immediately
        return pos;
      }
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 7),
      ),
    );

    if (position.isMocked) {
      throw Exception(l10n.mockLocationDetected);
    }

    return position;
  }

  Future<void> _refreshLocation() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoadingLocation = true;
      _locationMessage = null;
    });

    try {
      final position = await _getFreshPosition();

      if (!mounted) return;

      setState(() {
        _position = position;
        _locationMessage =
        _officeConfigured ? null : l10n.setOfficeCoordinates;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _locationMessage =
            error.toString().replaceFirst('Exception: ', '');
        _position = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _handleAttendanceAction() async {
    final l10n = AppLocalizations.of(context);

    if (!_officeConfigured) {
      setState(() {
      });
      return;
    }

    if (_isSubmittingAttendance) return;

    setState(() {
      _isSubmittingAttendance = true;
    });

    try {
      final position = await _getFreshPosition();

      if (position == null) {
        throw Exception(l10n.locationPermissionRequired);
      }

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        officeLatitude,
        officeLongitude,
      );

      if (distance > _geofenceRadiusMeters) {
        throw Exception(l10n.outsideBoundaryError);
      }

      if (!mounted) return;

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();

      final rawHistory = prefs.getString(_historyKey);
      final List<Map<String, dynamic>> records = [];

      if (rawHistory != null) {
        final decoded = jsonDecode(rawHistory);

        if (decoded is List) {
          records.addAll(
            decoded
                .whereType<Map>()
                .map((record) => Map<String, dynamic>.from(record)),
          );
        }
      }

      final today = _dateKey(now);

      Map<String, dynamic>? todayRecord;

      for (final record in records) {
        if (record['date'] == today) {
          todayRecord = record;
          break;
        }
      }

      if (todayRecord == null) {
        todayRecord = {
          'date': today,
          'sessions': <Map<String, dynamic>>[],
        };
        records.add(todayRecord);
      }

      final rawSessions = todayRecord['sessions'];

      final sessions = rawSessions is List
          ? rawSessions
          .whereType<Map>()
          .map((session) => Map<String, dynamic>.from(session))
          .toList()
          : <Map<String, dynamic>>[];

      final activeIndexes = <int>[];

      for (var i = 0; i < sessions.length; i++) {
        final session = sessions[i];

        if (session['checkInTime'] != null &&
            session['checkOutTime'] == null) {
          activeIndexes.add(i);
        }
      }

      if (_isCheckedIn) {
        // Check out the latest active session.
        if (activeIndexes.isEmpty) {
          throw StateError(
            'Attendance state is inconsistent. Refresh and try again.',
          );
        }

        final index = activeIndexes.last;

        sessions[index]['checkOutTime'] = now.toIso8601String();
        sessions[index]['checkOutType'] = 'manual';
      } else {
        if (activeIndexes.isNotEmpty) {
          throw StateError(
            'An active attendance session already exists.',
          );
        }

        // Create another session for the same day.
        sessions.add({
          'checkInTime': now.toIso8601String(),
          'checkOutTime': null,
          'checkOutType': null,
        });
      }

      todayRecord['sessions'] = sessions;

      final historySaved = await prefs.setString(
        _historyKey,
        jsonEncode(records),
      );

      if (!historySaved) {
        throw StateError('Could not save attendance history.');
      }

      final latest = sessions.last;
      final checkedIn = latest['checkOutTime'] == null;

      await prefs.setString('officecheck_date', today);
      await prefs.setBool('officecheck_checked_in', checkedIn);
      await prefs.setString(
        'officecheck_check_in_time',
        latest['checkInTime'].toString(),
      );

      if (latest['checkOutTime'] != null) {
        await prefs.setString(
          'officecheck_check_out_time',
          latest['checkOutTime'].toString(),
        );
      } else {
        await prefs.remove('officecheck_check_out_time');
      }

      if (!mounted) return;

      final message = checkedIn ? l10n.checkInRecorded : l10n.checkOutRecorded;

      setState(() {
        _position = position;
        _todaySessions = sessions;
        _isCheckedIn = checkedIn;
      });

      _showAttendanceDialog(
        title: checkedIn ? l10n.checkIn : l10n.checkOut,
        message: message,
        isSuccess: true,
      );
    } catch (error) {
      if (!mounted) return;

      final errorMsg = error.toString().replaceFirst('Exception: ', '');
      setState(() {
      });

      _showAttendanceDialog(
        title: 'Attendance Alert',
        message: errorMsg,
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingAttendance = false;
        });
      }
    }
  }

  void _showAttendanceDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.panel,
          shape: RoundedRectangleBorder(
            borderRadius: Sizes.radius20,
          ),
          contentPadding: AppPaddings.all24,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: isSuccess ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSuccess ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: isSuccess ? AppColors.success : AppColors.error,
                  size: 32,
                ),
              ),
              Sizes.gapH16,
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Sizes.gapH8,
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              Sizes.gapH20,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: isSuccess ? AppColors.blue : const Color(0xFF334155),
                    shape: RoundedRectangleBorder(
                      borderRadius: Sizes.radius12,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  // String _formatTime(DateTime? value) {
  //   if (value == null) return '--:--';
  //
  //   final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  //   final minute = value.minute.toString().padLeft(2, '0');
  //   final period = value.hour >= 12 ? 'PM' : 'AM';
  //
  //   return '$hour:$minute $period';
  // }
  //
  // String _formatDuration(Duration duration) {
  //   final hours = duration.inHours;
  //   final minutes = duration.inMinutes.remainder(60);
  //
  //   return '${hours}h ${minutes}m';
  // }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Wait for attendance and the first location check before
    // displaying the normal home screen.
    if (_isInitializing || _isLoadingLocation) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.blue,
              ),
              Sizes.gapH16,
              Text(
                l10n.statusChecking,
                style: TextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final inside = _isInsideOffice;
    final distance = _distanceMeters;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.blue,
          onRefresh: () async {
            await _loadAttendance();
            await _refreshLocation();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: Decorations.headerIconGradient,
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.white,
                      size: 26,
                    ),
                  ),
                  Sizes.gapW12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appTitle,
                          style: TextStyles.appBarTitle,
                        ),
                        Sizes.gapH4,
                        Text(
                          l10n.yourWorkplaceInRange,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.settings_rounded,
                      color: AppColors.blue,
                    ),
                  ),                ],
              ),
              Sizes.gapH26,
              _buildGeofenceCard(l10n, inside, distance),
              Sizes.gapH18,
              _buildAttendanceCard(l10n),
              if (_locationMessage != null) ...[
                Sizes.gapH16,
                FeedbackMessageCard(
                  icon: Icons.info_outline_rounded,
                  message: _locationMessage!,
                  isWarning: !_officeConfigured,
                ),
              ],
              // Today's attendance sessions and total duration.
              Sizes.gapH24,
              // Container(
              //   padding: AppPaddings.all20,
              //   decoration: Decorations.panelCard22,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         children: [
              //           Container(
              //             padding: AppPaddings.all8,
              //             decoration: BoxDecoration(
              //               color: const Color(0xFFEFF6FF),
              //               borderRadius: Sizes.radius12,
              //             ),
              //             child: const Icon(
              //               Icons.calendar_month_rounded,
              //               size: 20,
              //               color: AppColors.blue,
              //             ),
              //           ),
              //           Sizes.gapW12,
              //           Expanded(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   l10n.todaySessions,
              //                   style: TextStyles.sectionHeader,
              //                 ),
              //                 Sizes.gapH4,
              //                 Text(
              //                   l10n.todaySessionsSubtitle,
              //                   style: const TextStyle(
              //                     color: AppColors.muted,
              //                     fontSize: 12,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ],
              //       ),
              //       Sizes.gapH20,
              //       Container(
              //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              //         decoration: BoxDecoration(
              //           color: const Color(0xFFF8FAFC),
              //           borderRadius: Sizes.radius14,
              //           border: Border.all(color: AppColors.borderSubtle),
              //         ),
              //         child: Row(
              //           children: [
              //             const Icon(
              //               Icons.timelapse_rounded,
              //               color: AppColors.blue,
              //               size: 24,
              //             ),
              //             Sizes.gapW12,
              //             Expanded(
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   Text(
              //                     l10n.totalWorkHours,
              //                     style: const TextStyle(
              //                       color: AppColors.muted,
              //                       fontSize: 11,
              //                       fontWeight: FontWeight.w500,
              //                     ),
              //                   ),
              //                   Sizes.gapH4,
              //                   Text(
              //                     _formatDuration(_totalDuration),
              //                     style: const TextStyle(
              //                       color: AppColors.textPrimary,
              //                       fontSize: 18,
              //                       fontWeight: FontWeight.w700,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //             Container(
              //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              //               decoration: BoxDecoration(
              //                 color: AppColors.panel,
              //                 borderRadius: Sizes.radius12,
              //                 border: Border.all(color: AppColors.borderSubtle),
              //               ),
              //               child: Text(
              //                 '${_todaySessions.length} ${_todaySessions.length == 1 ? "Session" : "Sessions"}',
              //                 style: const TextStyle(
              //                   color: AppColors.blue,
              //                   fontSize: 11,
              //                   fontWeight: FontWeight.w600,
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       Sizes.gapH16,
              //
              //       if (_todaySessions.isEmpty)
              //         Container(
              //           padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              //           alignment: Alignment.center,
              //           decoration: BoxDecoration(
              //             color: const Color(0xFFFAFAFA),
              //             borderRadius: Sizes.radius14,
              //             border: Border.all(
              //               color: AppColors.borderSubtle,
              //               strokeAlign: BorderSide.strokeAlignCenter,
              //             ),
              //           ),
              //           child: Text(
              //             l10n.noAttendanceSessionsYet,
              //             textAlign: TextAlign.center,
              //             style: const TextStyle(
              //               color: AppColors.textSecondary,
              //               fontSize: 13,
              //               fontWeight: FontWeight.w500,
              //             ),
              //           ),
              //         )
              //       else ...[
              //         // Compact Table Header
              //         Container(
              //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              //           decoration: BoxDecoration(
              //             color: const Color(0xFFF1F5F9),
              //             borderRadius: Sizes.radius12,
              //           ),
              //           child: const Row(
              //             children: [
              //               Expanded(
              //                 flex: 3,
              //                 child: Text(
              //                   'Check In',
              //                   style: TextStyle(
              //                     color: AppColors.textSecondary,
              //                     fontSize: 12,
              //                     fontWeight: FontWeight.w700,
              //                   ),
              //                 ),
              //               ),
              //               Expanded(
              //                 flex: 3,
              //                 child: Text(
              //                   'Check Out',
              //                   style: TextStyle(
              //                     color: AppColors.textSecondary,
              //                     fontSize: 12,
              //                     fontWeight: FontWeight.w700,
              //                   ),
              //                 ),
              //               ),
              //               Expanded(
              //                 flex: 2,
              //                 child: Text(
              //                   'Duration',
              //                   textAlign: TextAlign.end,
              //                   style: TextStyle(
              //                     color: AppColors.textSecondary,
              //                     fontSize: 12,
              //                     fontWeight: FontWeight.w700,
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //         Sizes.gapH8,
              //         ..._todaySessions.asMap().entries.map((entry) {
              //           final session = entry.value;
              //
              //           final checkIn = _parseTime(session['checkInTime']);
              //           final checkOut = _parseTime(session['checkOutTime']);
              //           final isCompleted = !(checkIn != null && checkOut == null);
              //
              //           final duration = checkIn == null
              //               ? Duration.zero
              //               : (checkOut ?? DateTime.now()).difference(checkIn);
              //
              //           final isAutoGeofence = session['checkOutType'] == 'geofence';
              //
              //           return Container(
              //             margin: const EdgeInsets.symmetric(vertical: 3),
              //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              //             decoration: BoxDecoration(
              //               color: AppColors.panel,
              //               borderRadius: Sizes.radius12,
              //               border: Border.all(
              //                 color: isCompleted
              //                     ? AppColors.borderSubtle
              //                     : const Color(0xFFBFDBFE),
              //               ),
              //             ),
              //             child: Row(
              //               children: [
              //                 Expanded(
              //                   flex: 3,
              //                   child: Text(
              //                     _formatTime(checkIn),
              //                     style: const TextStyle(
              //                       color: AppColors.textPrimary,
              //                       fontSize: 13,
              //                       fontWeight: FontWeight.w600,
              //                     ),
              //                   ),
              //                 ),
              //                 Expanded(
              //                   flex: 3,
              //                   child: Row(
              //                     children: [
              //                       Text(
              //                         isCompleted
              //                             ? _formatTime(checkOut)
              //                             : l10n.activeSession,
              //                         style: TextStyle(
              //                           color: isCompleted
              //                               ? AppColors.textPrimary
              //                               : const Color(0xFFD97706),
              //                           fontSize: 13,
              //                           fontWeight: isCompleted
              //                               ? FontWeight.w600
              //                               : FontWeight.w700,
              //                         ),
              //                       ),
              //                       if (isAutoGeofence) ...[
              //                         const SizedBox(width: 4),
              //                         const Icon(
              //                           Icons.radar_rounded,
              //                           size: 13,
              //                           color: AppColors.blue,
              //                         ),
              //                       ],
              //                     ],
              //                   ),
              //                 ),
              //                 Expanded(
              //                   flex: 2,
              //                   child: Text(
              //                     _formatDuration(duration),
              //                     textAlign: TextAlign.end,
              //                     style: const TextStyle(
              //                       color: AppColors.blue,
              //                       fontSize: 13,
              //                       fontWeight: FontWeight.w700,
              //                     ),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           );
              //         }),
              //       ],
              //     ],
              //   ),
              // ),


              OutlinedButton.icon(
                onPressed: _openAttendanceHistory,
                icon: const Icon(Icons.history),
                label: const Text('View Attendance History'),
              ),

              // OutlinedButton.icon(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) =>
              //         const AttendanceCorrectionRequestScreen(),
              //       ),
              //     );
              //   },
              //   icon: const Icon(Icons.edit_calendar_outlined),
              //   label: const Text('Request Attendance Correction'),
              // ),

              Sizes.gapH24,
              Container(
                padding: AppPaddings.all16,
                decoration: Decorations.panelCard(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.blue,
                      size: 22,
                    ),
                    Sizes.gapW12,
                    Expanded(
                      child: Text(
                        l10n.freshLocationCheckNotice,
                        style: TextStyles.bodySmall12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeofenceCard(
      AppLocalizations l10n,
      bool inside,
      double? distance,
      ) {
    final statusColor = !_officeConfigured
        ? AppColors.muted
        : distance == null
        ? AppColors.blue
        : inside
        ? AppColors.success
        : const Color(0xFFD97706);

    final statusText = !_officeConfigured
        ? l10n.officeNotConfigured
        : distance == null
        ? l10n.checkingLocation
        : inside
        ? l10n.insideOfficeZone
        : l10n.outsideOfficeZone;

    return Container(
      padding: AppPaddings.all20,
      decoration: Decorations.proximityCard,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.officeProximity,
                  style: TextStyles.sectionHeader,
                ),
              ),
              StatusPill(
                text: inside && _officeConfigured
                    ? l10n.inRange
                    : l10n.statusBadge,
                color: statusColor,
              ),
            ],
          ),
          Sizes.gapH8,
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: Decorations.concentricCircle(
                    borderColor: const Color(0xFFBFDBFE),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: Decorations.concentricCircle(
                    borderColor: const Color(0xFF93C5FD),
                    fillColor: const Color(0x203B82F6),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: Decorations.circularHeroIcon,
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Sizes.gapH8,
          Text(
            statusText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: statusColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Sizes.gapH18,
          Row(
            children: [
              const Icon(
                Icons.radio_button_checked,
                color: AppColors.blue,
                size: Sizes.iconSm,
              ),
              Sizes.gapW8,
              Expanded(
                child: Text(
                  l10n.officeBoundary,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                l10n.radiusMeters,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildAttendanceCard(AppLocalizations l10n) {
    final checkedIn = _isCheckedIn;

    return Container(
      width: double.infinity,
      padding: AppPaddings.all20,
      decoration: Decorations.panelCard22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),

          // Centered work-hours heading
          const Text(
            "Today's work hours",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          Sizes.gapH8,
          Text(
            _formatDuration(_totalDuration),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Large centered attendance button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: FilledButton.icon(
              onPressed: _isSubmittingAttendance ||
                  _isLoadingLocation ||
                  !_officeConfigured
                  ? null
                  : _handleAttendanceAction,
              icon: _isSubmittingAttendance
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
                  : Icon(
                checkedIn
                    ? Icons.logout_rounded
                    : Icons.login_rounded,
                size: 34,
              ),
              label: Text(
                _isSubmittingAttendance
                    ? l10n.checkingLocation
                    : checkedIn
                    ? l10n.checkOut
                    : l10n.checkIn,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: checkedIn
                    ? Colors.orange
                    : AppColors.success,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          if (!_officeConfigured) ...[
            Sizes.gapH10,
            Text(
              l10n.attendanceAfterConfigNotice,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
