
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../location/data/services/geofencing_service.dart';

class BackgroundLocationScreen extends StatefulWidget {
  const BackgroundLocationScreen({
    super.key,
    this.onContinue,
  });

  final VoidCallback? onContinue;

  @override
  State<BackgroundLocationScreen> createState() =>
      _BackgroundLocationScreenState();
}

class _BackgroundLocationScreenState extends State<BackgroundLocationScreen> with WidgetsBindingObserver {
  static const _background = Color(0xFF071426);
  static const _blue = Color(0xFF3987FF);
  static const _cyan = Color(0xFF54E0E8);
  static const _muted = Color(0xFF9BB0C9);

  LocationPermission? _permission;
  bool _loading = true;
  String? _error;

  bool get _hasBackgroundAccess =>
      _permission == LocationPermission.always;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermission();
    }
  }

  static const double _officeLatitude = 12.9328497;
  static const double _officeLongitude = 77.5400525;

  final OfficeGeofencingService _geofencingService =
  OfficeGeofencingService();

  bool _isRegisteringGeofence = false;

  Future<void> _refreshPermission() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final permission = await Geolocator.checkPermission();

      if (!mounted) return;

      setState(() {
        _permission = permission;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not check permission. Please try again.';
      });

      debugPrint('Background permission check failed: $e');
    }
  }

  Future<void> _openSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
        'Could not open Settings. Please open OfficeCheck '
            'permissions from your device Settings.';
      });

      debugPrint('Opening app settings failed: $e');
    }
  }


  Future<void> _continueToHome() async {
    if (!_hasBackgroundAccess || _isRegisteringGeofence) {
      return;
    }

    setState(() {
      _isRegisteringGeofence = true;
      _error = null;
    });

    try {
      await _geofencingService.start(
        latitude: _officeLatitude,
        longitude: _officeLongitude,
      );

      if (!mounted) return;

      if (widget.onContinue != null) {
        widget.onContinue!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Home navigation is not connected yet.'),
          ),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Geofence registration failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _error =
        'Could not start office monitoring. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRegisteringGeofence = false;
        });
      }
    }
  }


  String get _status {
    if (_loading) return 'Checking...';

    if (_permission == LocationPermission.always) {
      return 'Enabled';
    }

    if (_permission == LocationPermission.whileInUse) {
      return 'While using';
    }

    if (_permission == LocationPermission.deniedForever) {
      return 'Blocked';
    }

    if (_permission == LocationPermission.denied) {
      return 'Not enabled';
    }

    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _hasBackgroundAccess;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'OFFICECHECK  •  SETUP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _cyan,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _blue.withValues(alpha: 0.08),
                        border: Border.all(
                          color: _cyan.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Icon(
                        enabled
                            ? Icons.verified_user_rounded
                            : Icons.location_on_rounded,
                        size: 78,
                        color: _cyan,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Stay connected\nwhen you step away.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Allow background location so OfficeCheck can '
                        'recognise office entry and exit when your phone '
                        'is locked or the app is not open.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Background permission status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10223A),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          color: _cyan,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Background location',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _status,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: enabled ? _cyan : _muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10223A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'In Android Settings, select Permissions → '
                          'Location → Allow all the time, if available. '
                          'The exact menu may vary by device.',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFFFC3CC),
                        fontSize: 13,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Main action
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                  onPressed: _loading || _isRegisteringGeofence
                  ? null
                      : enabled
                    ? _continueToHome
                    : _openSettings,
                    style: FilledButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading || _isRegisteringGeofence
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      enabled ? 'Next' : 'Open App Settings',
                    ),
                  ),
                  ),

                  const SizedBox(height: 10),

                  // Refresh status
                  TextButton(
                    onPressed: _loading ? null : _refreshPermission,
                    child: const Text(
                      'Refresh permission status',
                      style: TextStyle(color: _cyan),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    'Location is used for workplace attendance.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7188A5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
