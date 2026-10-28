import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/contants/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _geofenceRadiusMeters = 50;
  static const double officeLatitude = 12.9328497;
  static const double officeLongitude = 77.5400525;

  List<Map<String, dynamic>> _attendanceHistory = [];
  Position? _position;
  bool _isLoadingLocation = false;
  bool _isSubmittingAttendance = false;
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  String? _locationMessage;
  String? _attendanceMessage;

  bool get _officeConfigured => officeLatitude != null && officeLongitude != null;

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

  @override
  void initState() {
    super.initState();
    _loadAttendance();
    _refreshLocation();
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
      final historyJson =
      prefs.getString('officecheck_attendance_history');

      final List<dynamic> decoded = historyJson == null
          ? <dynamic>[]
          : jsonDecode(historyJson) as List<dynamic>;

      final history = decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
        ..sort(
              (a, b) => (b['date'] as String)
              .compareTo(a['date'] as String),
        );

      final today = _dateKey(DateTime.now());

      final todayRecords =
      history.where((record) => record['date'] == today);

      final Map<String, dynamic>? todayRecord =
      todayRecords.isEmpty ? null : todayRecords.first;

      if (!mounted) return;

      setState(() {
        _attendanceHistory = history;

        _checkInTime = todayRecord?['checkInTime'] == null
            ? null
            : DateTime.tryParse(
          todayRecord!['checkInTime'] as String,
        );

        _checkOutTime = todayRecord?['checkOutTime'] == null
            ? null
            : DateTime.tryParse(
          todayRecord!['checkOutTime'] as String,
        );

        _isCheckedIn =
            _checkInTime != null && _checkOutTime == null;
      });
    } catch (e) {
      debugPrint('Failed to load attendance history: $e');
    }
  }

  Future<Position?> _getFreshPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Turn on Location Services in your device settings.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission is required for attendance.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is blocked. Enable it in app settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    final age = DateTime.now().difference(position.timestamp).abs();
    if (age > const Duration(seconds: 30)) {
      throw Exception('Location is too old. Please try again.');
    }

    if (position.isMocked) {
      throw Exception('Mock location detected. Attendance was not recorded.');
    }

    return position;
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationMessage = null;
    });

    try {
      final position = await _getFreshPosition();
      if (!mounted) return;

      setState(() {
        _position = position;
        _locationMessage = _officeConfigured
            ? null
            : 'Set your office coordinates in HomeScreen before testing '
            'geofence attendance.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _locationMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }


  Future<void> _handleAttendanceAction() async {
    if (!_officeConfigured) {
      setState(() {
        _attendanceMessage = 'Office coordinates are not configured.';
      });
      return;
    }

    // A completed attendance record cannot be changed again today.
    if (_checkInTime != null && _checkOutTime != null) {
      setState(() {
        _attendanceMessage = 'Attendance is already completed for today.';
      });
      return;
    }

    setState(() {
      _isSubmittingAttendance = true;
      _attendanceMessage = null;
    });

    try {
      // Always validate using a fresh location.
      final position = await _getFreshPosition();

      if (position == null) {
        throw Exception('Unable to obtain your current location.');
      }

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        officeLatitude,
        officeLongitude,
      );

      if (distance > _geofenceRadiusMeters) {
        throw Exception(
          'You are outside the 150 m office boundary. '
              'Attendance was not recorded.',
        );
      }

      final now = DateTime.now();
      final today = _dateKey(now);
      final prefs = await SharedPreferences.getInstance();

      final historyJson =
      prefs.getString('officecheck_attendance_history');

      final List<dynamic> decoded = historyJson == null
          ? <dynamic>[]
          : jsonDecode(historyJson) as List<dynamic>;

      final history = decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final index = history.indexWhere(
            (record) => record['date'] == today,
      );

      late final Map<String, dynamic> record;
      late final bool isCheckIn;

      if (index == -1) {
        // No record exists today: create the one allowed check-in.
        record = <String, dynamic>{
          'date': today,
          'checkInTime': now.toIso8601String(),
          'checkOutTime': null,
          'status': 'incomplete',
        };

        history.add(record);
        isCheckIn = true;
      } else {
        // A record exists today. Only checkout is allowed now.
        record = history[index];

        if (record['checkInTime'] == null) {
          throw Exception('Invalid attendance record for today.');
        }

        if (record['checkOutTime'] != null) {
          throw Exception('Attendance is already completed for today.');
        }

        record['checkOutTime'] = now.toIso8601String();
        record['status'] = 'completed';

        history[index] = record;
        isCheckIn = false;
      }

      // Save all days, not just today's record.
      await prefs.setString(
        'officecheck_attendance_history',
        jsonEncode(history),
      );

      // Update legacy keys in case other existing code uses them.
      await prefs.setString('officecheck_date', today);
      await prefs.setBool(
        'officecheck_checked_in',
        isCheckIn,
      );

      await prefs.setString(
        'officecheck_check_in_time',
        record['checkInTime'] as String,
      );

      if (record['checkOutTime'] != null) {
        await prefs.setString(
          'officecheck_check_out_time',
          record['checkOutTime'] as String,
        );
      } else {
        await prefs.remove('officecheck_check_out_time');
      }

      if (!mounted) return;

      await _loadAttendance();

      if (!mounted) return;

      setState(() {
        _position = position;
        _attendanceMessage = isCheckIn
            ? 'Check In recorded on this device.'
            : 'Check Out recorded on this device.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _attendanceMessage =
            error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmittingAttendance = false);
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

  @override
  Widget build(BuildContext context) {
    final inside = _isInsideOffice;
    final distance = _distanceMeters;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.blue,
          onRefresh: _refreshLocation,
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OfficeCheck',
                          style: TextStyles.appBarTitle,
                        ),
                        Sizes.gapH4,
                        Text(
                          'Your workplace, in range.',
                          style: TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh location',
                    onPressed: _isLoadingLocation ? null : _refreshLocation,
                    icon: _isLoadingLocation
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.cyan,
                      ),
                    )
                        : const Icon(Icons.refresh_rounded, color: AppColors.cyan),
                  ),
                ],
              ),
              Sizes.gapH26,
              _buildGeofenceCard(inside, distance),
              Sizes.gapH18,
              _buildAttendanceCard(),
              if (_locationMessage != null) ...[
                Sizes.gapH16,
                _messageCard(
                  icon: Icons.info_outline_rounded,
                  message: _locationMessage!,
                  warning: !_officeConfigured,
                ),
              ],
              if (_attendanceMessage != null) ...[
                Sizes.gapH12,
                _messageCard(
                  icon: Icons.fact_check_outlined,
                  message: _attendanceMessage!,
                  warning: _attendanceMessage!.contains('not') ||
                      _attendanceMessage!.contains('outside') ||
                      _attendanceMessage!.contains('not configured'),
                ),
              ],
              Sizes.gapH26,
              const Text(
                'TODAY',
                style: TextStyles.sectionHeader,
              ),
              Sizes.gapH12,
              Row(
                children: [
                  Expanded(
                    child: _timeCard(
                      title: 'Check In',
                      time: _formatTime(_checkInTime),
                      icon: Icons.login_rounded,
                    ),
                  ),
                  Sizes.gapW12,
                  Expanded(
                    child: _timeCard(
                      title: 'Check Out',
                      time: _formatTime(_checkOutTime),
                      icon: Icons.logout_rounded,
                    ),
                  ),
                ],
              ),


              Sizes.gapH24,
              const Text(
                'ATTENDANCE HISTORY',
                style: TextStyles.sectionHeader,
              ),
              Sizes.gapH12,

              if (_attendanceHistory.isEmpty)
                const Text(
                  'No attendance history yet.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                )
              else
                ..._attendanceHistory.map((record) {
                  final checkIn = record['checkInTime'] == null
                      ? null
                      : DateTime.tryParse(
                    record['checkInTime'] as String,
                  );

                  final checkOut = record['checkOutTime'] == null
                      ? null
                      : DateTime.tryParse(
                    record['checkOutTime'] as String,
                  );

                  final date = record['date'] as String? ?? '';
                  final completed = checkOut != null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: AppPaddings.all14,
                      decoration: Decorations.panelCard(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  date,
                                  style: TextStyles.sectionTitle,
                                ),
                              ),
                              Text(
                                completed ? 'Completed' : 'Incomplete',
                                style: TextStyle(
                                  color: completed
                                      ? AppColors.cyan
                                      : const Color(0xFFFFC078),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Sizes.gapH8,
                          Text(
                            'Check In: ${_formatTime(checkIn)}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          Sizes.gapH4,
                          Text(
                            'Check Out: ${_formatTime(checkOut)}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              Sizes.gapH24,
              Container(
                padding: AppPaddings.all16,
                decoration: Decorations.panelCard(),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.cyan, size: 22),
                    Sizes.gapW12,
                    Expanded(
                      child: Text(
                        'Attendance is allowed only after a fresh location '
                            'check confirms you are within the office boundary.',
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

  Widget _buildGeofenceCard(bool inside, double? distance) {
    final statusColor = !_officeConfigured
        ? AppColors.muted
        : inside
        ? AppColors.cyan
        : const Color(0xFFFFC078);

    final statusText = !_officeConfigured
        ? 'Office not configured'
        : inside
        ? 'You are inside the office zone'
        : 'You are outside the office zone';

    return Container(
      padding: AppPaddings.all20,
      decoration: Decorations.proximityCard,
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'OFFICE PROXIMITY',
                  style: TextStyles.sectionHeader,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: Decorations.statusPill(statusColor),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: statusColor, size: 7),
                    Sizes.gapW4,
                    Text(
                      inside && _officeConfigured ? 'IN RANGE' : 'STATUS',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Sizes.gapH20,
          SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 164,
                  height: 164,
                  decoration: Decorations.concentricCircle(
                    borderColor: AppColors.blue.withValues(alpha: 0.3),
                  ),
                ),
                Container(
                  width: 126,
                  height: 126,
                  decoration: Decorations.concentricCircle(
                    borderColor: AppColors.cyan.withValues(alpha: 0.4),
                    fillColor: AppColors.cyan.withValues(alpha: 0.05),
                  ),
                ),
                Container(
                  width: 82,
                  height: 82,
                  decoration: Decorations.circularHeroIcon,
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: AppColors.white,
                    size: 38,
                  ),
                ),
              ],
            ),
          ),
          Sizes.gapH14,
          Text(
            distance == null ? '-- m' : '${distance.round()} m',
            style: TextStyles.metricLarge,
          ),
          Sizes.gapH4,
          Text(
            statusText,
            textAlign: TextAlign.center,
            style: TextStyle(color: statusColor, fontSize: 13),
          ),
          Sizes.gapH18,
          Row(
            children: [
              const Icon(Icons.radio_button_checked, color: AppColors.cyan, size: Sizes.iconSm),
              Sizes.gapW8,
              const Expanded(
                child: Text(
                  'Office boundary',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
              const Text(
                '50 m radius',
                style: TextStyle(
                  color: AppColors.white,
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

  Widget _buildAttendanceCard() {
    final checkedIn = _isCheckedIn;
    final completedToday =
        _checkInTime != null && _checkOutTime != null;

    return Container(
      padding: AppPaddings.all20,
      decoration: Decorations.panelCard22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ATTENDANCE',
            style: TextStyles.sectionHeader,
          ),
          Sizes.gapH12,
          Row(
            children: [
              Icon(
                checkedIn ? Icons.check_circle_rounded : Icons.schedule_rounded,
                color: checkedIn ? AppColors.cyan : AppColors.muted,
                size: 25,
              ),
              Sizes.gapW10,
              Expanded(
                child: Text(
                  checkedIn ? 'You are checked in' : 'Not checked in yet',
                  style: TextStyles.sectionTitle,
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
                  !_officeConfigured ||
                  completedToday
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
                checkedIn ? Icons.logout_rounded : Icons.login_rounded,
              ),
              label: Text(
                _isSubmittingAttendance
                    ? 'Checking location...'
                    : completedToday
                    ? 'Completed for today'
                    : checkedIn
                    ? 'Check Out'
                    : 'Check In',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: checkedIn
                    ? const Color(0xFF263B54)
                    : AppColors.blue,
                disabledBackgroundColor: AppColors.blue.withValues(alpha: 0.25),
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
            const Text(
              'Attendance actions will be enabled after the office coordinates are configured.',
              style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeCard({
    required String title,
    required String time,
    required IconData icon,
  }) {
    return Container(
      padding: AppPaddings.card,
      decoration: Decorations.panelCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.cyan, size: Sizes.iconMd),
          Sizes.gapH12,
          Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          Sizes.gapH4,
          Text(
            time,
            style: TextStyles.timeDisplay,
          ),
        ],
      ),
    );
  }

  Widget _messageCard({
    required IconData icon,
    required String message,
    required bool warning,
  }) {
    final color = warning ? const Color(0xFFFFC078) : AppColors.cyan;

    return Container(
      padding: AppPaddings.all14,
      decoration: Decorations.messageCard(color),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          Sizes.gapW10,
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
