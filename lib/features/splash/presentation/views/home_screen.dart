
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/contants/constants.dart';
import '../../../../core/localization/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  static const double _geofenceRadiusMeters = 150;
  static const double officeLatitude = 12.9328497;
  static const double officeLongitude = 77.5400525;

  static const String _historyKey = 'officecheck_attendance_history';

  Position? _position;
  StreamSubscription<Position>? _positionStreamSubscription;

  bool _isInitializing = true;
  bool _isLoadingLocation = false;
  bool _isSubmittingAttendance = false;
  bool _isCheckedIn = false;

  DateTime? _checkInTime;
  DateTime? _checkOutTime;

  String? _locationMessage;
  String? _attendanceMessage;

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
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
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

      // Migrate legacy attendance data when no session history exists.
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
        _checkInTime = _parseTime(checkInValue);
        _checkOutTime = _parseTime(checkOutValue);
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

    // Otherwise obtain current position with balanced settings so it resolves promptly
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
        _attendanceMessage = l10n.officeNotConfiguredWarning;
      });
      return;
    }

    if (_isSubmittingAttendance) return;

    setState(() {
      _isSubmittingAttendance = true;
      _attendanceMessage = null;
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

      setState(() {
        _position = position;
        _todaySessions = sessions;
        _isCheckedIn = checkedIn;
        _checkInTime = _parseTime(latest['checkInTime']);
        _checkOutTime = _parseTime(latest['checkOutTime']);
        _attendanceMessage = checkedIn
            ? l10n.checkInRecorded
            : l10n.checkOutRecorded;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _attendanceMessage =
            error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingAttendance = false;
        });
      }
    }
  }

  String _formatTime(DateTime? value) {
    if (value == null) return '--:--';

    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '${hours}h ${minutes}m';
  }

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
                    tooltip: l10n.refreshLocationTooltip,
                    onPressed:
                    _isLoadingLocation ? null : _refreshLocation,
                    icon: _isLoadingLocation
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.blue,
                      ),
                    )
                        : const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.blue,
                    ),
                  ),
                ],
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
              if (_attendanceMessage != null) ...[
                Sizes.gapH12,
                FeedbackMessageCard(
                  icon: Icons.fact_check_outlined,
                  message: _attendanceMessage!,
                  isWarning:
                  _attendanceMessage!.toLowerCase().contains('outside') ||
                      _attendanceMessage!.toLowerCase().contains('not'),
                ),
              ],
              // Today's attendance sessions and total duration.
              Sizes.gapH24,
              Container(
                padding: AppPaddings.all20,
                decoration: Decorations.panelCard22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: AppPaddings.all8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: Sizes.radius12,
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            size: 20,
                            color: AppColors.blue,
                          ),
                        ),
                        Sizes.gapW12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.todaySessions,
                                style: TextStyles.sectionHeader,
                              ),
                              Sizes.gapH4,
                              Text(
                                l10n.todaySessionsSubtitle,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Sizes.gapH20,

                    // Summary Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: Sizes.radius14,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timelapse_rounded,
                            color: AppColors.blue,
                            size: 24,
                          ),
                          Sizes.gapW12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.totalWorkHours,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Sizes.gapH4,
                                Text(
                                  _formatDuration(_totalDuration),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.panel,
                              borderRadius: Sizes.radius12,
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Text(
                              '${_todaySessions.length} ${_todaySessions.length == 1 ? "Session" : "Sessions"}',
                              style: const TextStyle(
                                color: AppColors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Sizes.gapH16,

                    if (_todaySessions.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: Sizes.radius14,
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            strokeAlign: BorderSide.strokeAlignCenter,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.history_toggle_off_rounded,
                              size: 40,
                              color: AppColors.textSubtle,
                            ),
                            Sizes.gapH10,
                            Text(
                              l10n.noAttendanceSessionsYet,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._todaySessions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final session = entry.value;

                        final checkIn = _parseTime(session['checkInTime']);
                        final checkOut = _parseTime(session['checkOutTime']);
                        final isCompleted = !(checkIn != null && checkOut == null);

                        final duration = checkIn == null
                            ? Duration.zero
                            : (checkOut ?? DateTime.now()).difference(checkIn);

                        final isAutoGeofence = session['checkOutType'] == 'geofence';

                        return SessionTimelineCard(
                          sessionNumber: index + 1,
                          checkInFormatted: _formatTime(checkIn),
                          checkOutFormatted: isCompleted
                              ? _formatTime(checkOut)
                              : l10n.activeSession,
                          durationFormatted: _formatDuration(duration),
                          isCompleted: isCompleted,
                          isAutoGeofence: isAutoGeofence,
                        );
                      }),
                  ],
                ),
              ),
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
      padding: AppPaddings.all20,
      decoration: Decorations.panelCard22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                checkedIn
                    ? Icons.check_circle_rounded
                    : Icons.schedule_rounded,
                color: checkedIn
                    ? AppColors.success
                    : AppColors.muted,
                size: 24,
              ),
              Sizes.gapW10,
              Expanded(
                child: Text(
                  checkedIn ? l10n.checkIn : l10n.checkOut,
                  style: TextStyles.sectionHeader,
                ),
              ),
            ],
          ),
          Sizes.gapH18,
          SizedBox(
            width: double.infinity,
            height: Sizes.buttonHeight,
            child: FilledButton.icon(
              onPressed: _isSubmittingAttendance ||
                  _isLoadingLocation ||
                  !_officeConfigured
                  ? null
                  : _handleAttendanceAction,
              icon: _isSubmittingAttendance
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
                  : Icon(
                checkedIn
                    ? Icons.logout_rounded
                    : Icons.login_rounded,
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
                    ? const Color(0xFF475569)
                    : AppColors.blue,
                disabledBackgroundColor:
                AppColors.blue.withValues(alpha: 0.25),
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: Sizes.radius16,
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (!_officeConfigured) ...[
            Sizes.gapH10,
            Text(
              l10n.attendanceAfterConfigNotice,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
