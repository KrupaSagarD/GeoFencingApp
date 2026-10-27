import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'background_location_screen.dart';
import 'get_notified_screen.dart';
import 'home_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with WidgetsBindingObserver {
  static const Color _background = Color(0xFF071426);
  static const Color _blue = Color(0xFF3987FF);
  static const Color _cyan = Color(0xFF54E0E8);
  static const Color _muted = Color(0xFF9BB0C9);

  LocationPermission? _permission;
  bool _locationServicesEnabled = false;
  bool _isRequesting = false;
  String? _errorMessage;

  bool get _hasLocationPermission =>
      _permission == LocationPermission.whileInUse || _permission == LocationPermission.always;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final results = await Future.wait<Object>([
      Geolocator.checkPermission(),
      Geolocator.isLocationServiceEnabled(),
    ]);

    if (!mounted) return;

    setState(() {
      _permission = results[0] as LocationPermission;
      _locationServicesEnabled = results[1] as bool;
    });
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isRequesting = true;
      _errorMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationServicesEnabled = false;
            _errorMessage =
                'Location services are turned off. Please enable '
                'them in your device settings.';
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _locationServicesEnabled = true;
        });
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!mounted) return;

      setState(() {
        _permission = permission;
      });

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location access was permanently denied. '
              'Please enable it in app settings.';
        });
      } else if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage =
              'Location access is needed to detect your arrival '
              'at the office.';
        });
      }
    }  catch (e, stackTrace) {
  debugPrint('Location permission error: $e');
  debugPrintStack(stackTrace: stackTrace);

  if (mounted) {
    setState(() {
      _errorMessage = 'Location setup failed. Please try again.';
    });
  }
  }finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  Future<void> _openSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> _handleLocationButton() async {
    if (_hasLocationPermission && !_locationServicesEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    if (_permission == LocationPermission.deniedForever) {
      await _openSettings();
      return;
    }

    await _requestLocationPermission();
  }

  void _showBackgroundInfo() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF10223A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_searching_rounded, color: _cyan, size: 32),
                const SizedBox(height: 18),
                const Text(
                  'Why background location?',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                const Text(
                  'OfficeCheck needs background location access '
                  'to detect when you enter or leave the office '
                  'while your phone is locked or the app is not open.',
                  style: TextStyle(color: _muted, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Android handles this separately from foreground '
                  'location access. We will guide you through the '
                  'required settings in the next setup step.',
                  style: TextStyle(color: _muted, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          Positioned(top: -130, right: -110, child: _glow(300, _blue.withValues(alpha: 0.13))),
          Positioned(bottom: 50, left: -150, child: _glow(300, _cyan.withValues(alpha: 0.07))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildIllustration(),
                      const SizedBox(height: 32),

                      const Text(
                        'Stay in the loop.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Let OfficeCheck recognise your arrival '
                        'and departure without keeping the app open.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _muted, fontSize: 15, height: 1.6),
                      ),

                      const SizedBox(height: 30),

                      _permissionRow(
                        icon: Icons.my_location_rounded,
                        title: 'Precise location',
                        subtitle:
                            'Check whether you are within 150 m '
                            'of your office.',
                        status: !_locationServicesEnabled
                            ? 'Services off'
                            : _hasLocationPermission
                            ? 'Granted'
                            : 'Needed',
                        granted: _hasLocationPermission && _locationServicesEnabled,
                      ),
                      const SizedBox(height: 12),
                      _permissionRow(
                        icon: Icons.nightlight_round,
                        title: 'Background access',
                        subtitle:
                            'Detect arrival and departure while '
                            'your phone is locked.',
                        status: 'Setup next',
                        granted: false,
                      ),
                      const SizedBox(height: 12),
                      _permissionRow(
                        icon: Icons.notifications_active_outlined,
                        title: 'Notifications',
                        subtitle:
                            'Receive a prompt to confirm '
                            'Check In or Check Out.',
                        status: 'Setup next',
                        granted: false,
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF451F2B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF8E3D4B)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFFFC3CC),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 26),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          onPressed: _isRequesting
                              ? null
                              : (_hasLocationPermission && _locationServicesEnabled)
                              ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => GetNotifiedScreen(
                                  onContinue: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => BackgroundLocationScreen(
                                          onContinue: () {
                                            Navigator.of(context).pushReplacement(
                                              MaterialPageRoute<void>(
                                                builder: (_) => const HomeScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                              : _handleLocationButton,
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            disabledBackgroundColor: _blue.withValues(alpha: 0.45),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isRequesting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _hasLocationPermission && _locationServicesEnabled
                                          ? Icons.check_circle_outline
                                          : (_hasLocationPermission && !_locationServicesEnabled)
                                          ? Icons.location_off_rounded
                                          : _permission == LocationPermission.deniedForever
                                          ? Icons.settings_outlined
                                          : Icons.location_on_rounded,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _hasLocationPermission && _locationServicesEnabled
                                          ? 'Location Access Enabled'
                                          : (_hasLocationPermission && !_locationServicesEnabled)
                                          ? 'Enable Device Location'
                                          : _permission == LocationPermission.deniedForever
                                          ? 'Open App Settings'
                                          : 'Enable Location Access',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: _showBackgroundInfo,
                        child: const Text(
                          'Why do we need background access?',
                          style: TextStyle(color: _cyan, fontWeight: FontWeight.w500),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'YOUR LOCATION IS USED FOR WORKPLACE '
                        'ATTENDANCE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF7188A5),
                          fontSize: 10,
                          letterSpacing: 1.1,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 184,
            height: 184,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _blue.withValues(alpha: 0.2)),
            ),
          ),
          Container(
            width: 145,
            height: 145,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _blue.withValues(alpha: 0.07),
              border: Border.all(color: _cyan.withValues(alpha: 0.35)),
            ),
          ),
          Container(
            width: 98,
            height: 98,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3987FF), Color(0xFF164BC0)],
              ),
              boxShadow: [
                BoxShadow(color: _blue.withValues(alpha: 0.3), blurRadius: 32, spreadRadius: 2),
              ],
            ),
            child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 54),
          ),
          Positioned(
            top: 18,
            right: 25,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF102B43),
                shape: BoxShape.circle,
                border: Border.all(color: _cyan.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.verified_user_rounded, color: _cyan, size: 21),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required bool granted,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF10223A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: _cyan, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11, height: 1.45)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            granted ? Icons.check_circle : Icons.arrow_forward_ios_rounded,
            color: granted ? _cyan : _muted,
            size: granted ? 19 : 15,
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
