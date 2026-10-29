
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/contants/colors.dart';
import '../../../location/data/services/attendance_service.dart';
import '../../../location/data/services/geofencing_service.dart';
import 'home_screen.dart';

class LocationAccessScreen extends StatefulWidget {
  const LocationAccessScreen({super.key});

  @override
  State<LocationAccessScreen> createState() =>
      _LocationAccessScreenState();
}

class _LocationAccessScreenState extends State<LocationAccessScreen>
    with WidgetsBindingObserver {
  static const double _officeLatitude = 12.9328497;
  static const double _officeLongitude = 77.5400525;

  final OfficeGeofencingService _geofencingService =
  OfficeGeofencingService();

  LocationPermission _locationPermission = LocationPermission.denied;

  bool _locationServicesEnabled = false;
  bool _notificationsEnabled = false;
  bool _isLoading = true;
  bool _isContinuing = false;
  String? _errorMessage;

  bool get _hasForegroundPermission =>
      _locationPermission == LocationPermission.whileInUse ||
          _locationPermission == LocationPermission.always;

  bool get _hasBackgroundPermission =>
      _locationPermission == LocationPermission.always;

  bool get _requiredPermissionsGranted =>
      _locationServicesEnabled &&
          _hasForegroundPermission &&
          _hasBackgroundPermission;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions();
    }
  }

  Future<void> _refreshPermissions() async {
    try {
      final results = await Future.wait<Object>([
        Geolocator.isLocationServiceEnabled(),
        Geolocator.checkPermission(),
        Permission.notification.status,
      ]);

      if (!mounted) return;

      setState(() {
        _locationServicesEnabled = results[0] as bool;
        _locationPermission = results[1] as LocationPermission;
        _notificationsEnabled =
            (results[2] as PermissionStatus).isGranted;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error, stackTrace) {
      debugPrint('Permission refresh failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Unable to check permissions. Please try again.';
      });
    }
  }

  Future<void> _enableLocation() async {
    try {
      final servicesEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!servicesEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!mounted) return;

      setState(() {
        _locationServicesEnabled = true;
        _locationPermission = permission;
        _errorMessage = null;
      });

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await openAppSettings();
      }
    } catch (error, stackTrace) {
      debugPrint('Foreground location error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _errorMessage =
        'Could not enable location. Please check App Settings.';
      });
    } finally {
      if (mounted) {
        await _refreshPermissions();
      }
    }
  }

  Future<void> _enableBackgroundLocation() async {
    try {
      final servicesEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!servicesEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      final permission = await Geolocator.checkPermission();

      if (!mounted) return;

      setState(() {
        _locationServicesEnabled = true;
        _locationPermission = permission;
        _errorMessage = null;
      });

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await _enableLocation();
        return;
      }

      if (permission != LocationPermission.always) {
        await openAppSettings();
      }
    } catch (error, stackTrace) {
      debugPrint('Background location error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _errorMessage =
        'Could not open location settings. Please try again.';
      });
    } finally {
      if (mounted) {
        await _refreshPermissions();
      }
    }
  }

  Future<void> _enableNotifications() async {
    try {
      final status = await Permission.notification.status;

      if (status.isGranted) {
        if (mounted) {
          setState(() => _notificationsEnabled = true);
        }
        return;
      }

      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return;
      }

      final result = await Permission.notification.request();

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = result.isGranted;
      });
    } catch (error, stackTrace) {
      debugPrint('Notification permission error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        await _refreshPermissions();
      }
    }
  }

  Future<void> _handleOfficeExit(DateTime eventTime) async {
    debugPrint(
      'LocationAccessScreen: geofence exit at $eventTime; auto checkout',
    );

    final success = await AttendanceService.autoCheckout(eventTime);

    debugPrint('AttendanceService.autoCheckout result: $success');
  }

  Future<void> _continueToHome() async {
    if (_isContinuing) return;

    setState(() {
      _isContinuing = true;
      _errorMessage = null;
    });

    try {
      await _refreshPermissions();

      if (!mounted) return;

      if (!_requiredPermissionsGranted) {
        setState(() {
          _errorMessage =
          'Enable device location and grant "Allow all the time" '
              'to continue.';
          _isContinuing = false;
        });
        return;
      }

      await _geofencingService.start(
        latitude: _officeLatitude,
        longitude: _officeLongitude,
        onOfficeExit: _handleOfficeExit,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Geofence setup failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _errorMessage =
        'Could not start background location monitoring. '
            'Please check your permissions and try again.';
        _isContinuing = false;
      });
    }
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    required String status,
    required VoidCallback onPressed,
    bool optional = false,
  })
  {
    final statusColor = isGranted
        ? AppColors.success
        : optional
        ? AppColors.muted
        : AppColors.error;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isGranted
              ? AppColors.successBorder
              : AppColors.borderSubtle,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      isGranted
                          ? Icons.check_circle_rounded
                          : optional
                          ? Icons.info_outline_rounded
                          : Icons.error_outline_rounded,
                      size: 15,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!isGranted)
                      TextButton(
                        onPressed: onPressed,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        child: const Text('Enable'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationReady =
        _locationServicesEnabled && _hasForegroundPermission;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.blueGradientStart,
                            AppColors.blueGradientEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Set up your location',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'OfficeCheck needs location access to verify '
                          'your office attendance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          color: AppColors.blue,
                        ),
                      ),
                    )
                  else ...[
                    _buildPermissionCard(
                      icon: Icons.my_location_rounded,
                      title: 'Device and foreground location',
                      description:
                      'Turn on device location and allow the app '
                          'to access your location while in use.',
                      isGranted: locationReady,
                      status: !_locationServicesEnabled
                          ? 'Device location is off'
                          : _hasForegroundPermission
                          ? 'Location access enabled'
                          : 'Permission required',
                      onPressed: _enableLocation,
                    ),
                    _buildPermissionCard(
                      icon: Icons.location_searching_rounded,
                      title: 'Background location',
                      description:
                      'Select "Allow all the time" in App Settings '
                          'so office entry and exit can be detected '
                          'when the app is not open.',
                      isGranted: _hasBackgroundPermission,
                      status: _hasBackgroundPermission
                          ? 'Always allowed'
                          : 'Required for background monitoring',
                      onPressed: _enableBackgroundLocation,
                    ),
                    _buildPermissionCard(
                      icon: Icons.notifications_active_outlined,
                      title: 'Notifications',
                      description:
                      'Receive attendance reminders and location '
                          'event notifications. You can enable these later.',
                      isGranted: _notificationsEnabled,
                      status: _notificationsEnabled
                          ? 'Notifications enabled'
                          : 'Optional',
                      onPressed: _enableNotifications,
                      optional: true,
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorBackground,
                        border: Border.all(
                          color: AppColors.errorBorder,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.errorText,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ||
                          _isContinuing ||
                          !_requiredPermissionsGranted
                          ? null
                          : _continueToHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        disabledBackgroundColor: AppColors.panelAlt,
                        foregroundColor: AppColors.white,
                        disabledForegroundColor: AppColors.muted,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isContinuing
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                          : const Text(
                        'Continue to OfficeCheck',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Background location is required for automatic '
                          'office-exit detection. Notifications are optional.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
