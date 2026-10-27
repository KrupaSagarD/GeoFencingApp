import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _background = Color(0xFF071426);
  static const Color _panel = Color(0xFF10223A);
  static const Color _blue = Color(0xFF3987FF);
  static const Color _cyan = Color(0xFF54E0E8);
  static const Color _muted = Color(0xFF9BB0C9);
  static const double _geofenceRadiusMeters = 150;

  static const double officeLatitude = 12.9328497;
  static const double officeLongitude = 77.5400525;

  Position? _position;
  bool _isLoadingLocation = false;
  bool _isSubmittingAttendance = false;
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  String? _locationMessage;
  String? _attendanceMessage;

  bool get _officeConfigured =>
      officeLatitude != null && officeLongitude != null;

  double? get _distanceMeters {
    final position = _position;
    if (position == null || !_officeConfigured) return null;

    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      officeLatitude!,
      officeLongitude!,
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
      final today = _dateKey(DateTime.now());
      final savedDate = prefs.getString('officecheck_date');

      // Start a new daily record when the date changes.
      if (savedDate != today) {
        await prefs.setString('officecheck_date', today);
        await prefs.setBool('officecheck_checked_in', false);
        await prefs.remove('officecheck_check_in_time');
        await prefs.remove('officecheck_check_out_time');

        if (!mounted) return;

        setState(() {
          _isCheckedIn = false;
          _checkInTime = null;
          _checkOutTime = null;
        });

        return;
      }

      final checkInString =
      prefs.getString('officecheck_check_in_time');
      final checkOutString =
      prefs.getString('officecheck_check_out_time');

      if (!mounted) return;

      setState(() {
        _isCheckedIn =
            prefs.getBool('officecheck_checked_in') ?? false;
        _checkInTime = checkInString == null
            ? null
            : DateTime.tryParse(checkInString);
        _checkOutTime = checkOutString == null
            ? null
            : DateTime.tryParse(checkOutString);
      });
    } catch (e) {
      debugPrint('Failed to load attendance: $e');
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
        _attendanceMessage =
        'Office coordinates are not configured yet. Set them in '
            'HomeScreen before using attendance.';
      });
      return;
    }

    setState(() {
      _isSubmittingAttendance = true;
      _attendanceMessage = null;
    });

    try {
      // Fetch a fresh position at the moment of the attendance action.
      // Do not rely only on the last displayed location.
      final position = await _getFreshPosition();
      final distance = Geolocator.distanceBetween(
        position!.latitude,
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

      if (!mounted) return;

      final now = DateTime.now();
      final nextCheckedIn = !_isCheckedIn;

      final nextCheckInTime =
      nextCheckedIn ? now : _checkInTime;

      final nextCheckOutTime =
      nextCheckedIn ? _checkOutTime : now;

// Save before updating the visible attendance state.
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'officecheck_date',
        _dateKey(now),
      );

      await prefs.setBool(
        'officecheck_checked_in',
        nextCheckedIn,
      );

      if (nextCheckInTime != null) {
        await prefs.setString(
          'officecheck_check_in_time',
          nextCheckInTime.toIso8601String(),
        );
      }

      if (nextCheckOutTime != null) {
        await prefs.setString(
          'officecheck_check_out_time',
          nextCheckOutTime.toIso8601String(),
        );
      }

      if (!mounted) return;

      setState(() {
        _position = position;
        _isCheckedIn = nextCheckedIn;
        _checkInTime = nextCheckInTime;
        _checkOutTime = nextCheckOutTime;

        _attendanceMessage = nextCheckedIn
            ? 'Check In recorded on this device.'
            : 'Check Out recorded on this device.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _attendanceMessage = error.toString().replaceFirst('Exception: ', '');
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
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          color: _blue,
          onRefresh: _refreshLocation,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [_blue, Color(0xFF164BC0)],
                      ),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OfficeCheck',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Your workplace, in range.',
                          style: TextStyle(color: _muted, fontSize: 12),
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
                        color: _cyan,
                      ),
                    )
                        : const Icon(Icons.refresh_rounded, color: _cyan),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _buildGeofenceCard(inside, distance),
              const SizedBox(height: 18),
              _buildAttendanceCard(),
              if (_locationMessage != null) ...[
                const SizedBox(height: 16),
                _messageCard(
                  icon: Icons.info_outline_rounded,
                  message: _locationMessage!,
                  warning: !_officeConfigured,
                ),
              ],
              if (_attendanceMessage != null) ...[
                const SizedBox(height: 12),
                _messageCard(
                  icon: Icons.fact_check_outlined,
                  message: _attendanceMessage!,
                  warning: _attendanceMessage!.contains('not') ||
                      _attendanceMessage!.contains('outside') ||
                      _attendanceMessage!.contains('not configured'),
                ),
              ],
              const SizedBox(height: 26),
              const Text(
                'TODAY',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _timeCard(
                      title: 'Check In',
                      time: _formatTime(_checkInTime),
                      icon: Icons.login_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _timeCard(
                      title: 'Check Out',
                      time: _formatTime(_checkOutTime),
                      icon: Icons.logout_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: _cyan, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Attendance is allowed only after a fresh location '
                            'check confirms you are within the office boundary.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 12,
                          height: 1.55,
                        ),
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
        ? _muted
        : inside
        ? _cyan
        : const Color(0xFFFFC078);

    final statusText = !_officeConfigured
        ? 'Office not configured'
        : inside
        ? 'You are inside the office zone'
        : 'You are outside the office zone';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14345A), Color(0xFF0D2038)],
        ),
        border: Border.all(color: _blue.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'OFFICE PROXIMITY',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: statusColor, size: 7),
                    const SizedBox(width: 6),
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
          const SizedBox(height: 20),
          SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 164,
                  height: 164,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _blue.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Container(
                  width: 126,
                  height: 126,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _cyan.withValues(alpha: 0.05),
                    border: Border.all(
                      color: _cyan.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_blue, Color(0xFF164BC0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _blue.withValues(alpha: 0.28),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            distance == null ? '-- m' : '${distance.round()} m',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            statusText,
            textAlign: TextAlign.center,
            style: TextStyle(color: statusColor, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.radio_button_checked, color: _cyan, size: 16),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Office boundary',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ),
              const Text(
                '150 m radius',
                style: TextStyle(
                  color: Colors.white,
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ATTENDANCE',
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                checkedIn ? Icons.check_circle_rounded : Icons.schedule_rounded,
                color: checkedIn ? _cyan : _muted,
                size: 25,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  checkedIn ? 'You are checked in' : 'Not checked in yet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
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
                  color: Colors.white,
                ),
              )
                  : Icon(
                checkedIn ? Icons.logout_rounded : Icons.login_rounded,
              ),
              label: Text(
                _isSubmittingAttendance
                    ? 'Checking location...'
                    : checkedIn
                    ? 'Check Out'
                    : 'Check In',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: checkedIn
                    ? const Color(0xFF263B54)
                    : _blue,
                disabledBackgroundColor: _blue.withValues(alpha: 0.25),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (!_officeConfigured) ...[
            const SizedBox(height: 10),
            const Text(
              'Attendance actions will be enabled after the office '
                  'coordinates are configured.',
              style: TextStyle(color: _muted, fontSize: 11, height: 1.5),
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _cyan, size: 20),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: _muted, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
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
    final color = warning ? const Color(0xFFFFC078) : _cyan;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 10),
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
