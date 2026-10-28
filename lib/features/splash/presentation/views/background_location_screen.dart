import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/contants/constants.dart';
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
  LocationPermission? _permission;
  bool _loading = true;
  String? _error;

  bool get _hasBackgroundAccess => _permission == LocationPermission.always;

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

  final OfficeGeofencingService _geofencingService = OfficeGeofencingService();

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
        _error = 'Could not start office monitoring. Please try again.';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppPaddings.screen,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Sizes.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'OFFICECHECK  •  SETUP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.cyan,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Sizes.gapH32,
                  Center(
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: Decorations.concentricCircle(
                        borderColor: AppColors.cyan.withValues(alpha: 0.35),
                        fillColor: AppColors.blue.withValues(alpha: 0.08),
                      ),
                      child: Icon(
                        enabled
                            ? Icons.verified_user_rounded
                            : Icons.location_on_rounded,
                        size: 78,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                  Sizes.gapH30,
                  const Text(
                    'Stay connected\nwhen you step away.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 29,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Sizes.gapH14,
                  const Text(
                    'Allow background location so OfficeCheck can '
                    'recognise office entry and exit when your phone '
                    'is locked or the app is not open.',
                    textAlign: TextAlign.center,
                    style: TextStyles.bodyMedium,
                  ),
                  Sizes.gapH28,

                  Container(
                    padding: AppPaddings.all16,
                    decoration: Decorations.panelCard18,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          color: AppColors.cyan,
                          size: 28,
                        ),
                        Sizes.gapW12,
                        const Expanded(
                          child: Text(
                            'Background location',
                            style: TextStyles.itemTitle,
                          ),
                        ),
                        Sizes.gapW8,
                        Flexible(
                          child: Text(
                            _status,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: enabled ? AppColors.cyan : AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Sizes.gapH16,

                  Container(
                    padding: AppPaddings.all15,
                    decoration: Decorations.panelCard16,
                    child: const Text(
                      'In Android Settings, select Permissions → '
                      'Location → Allow all the time, if available. '
                      'The exact menu may vary by device.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),

                  if (_error != null) ...[
                    Sizes.gapH16,
                    AppErrorBanner(message: _error!),
                  ],

                  Sizes.gapH24,

                  SizedBox(
                    width: double.infinity,
                    height: Sizes.buttonHeight,
                    child: FilledButton(
                      onPressed: _loading || _isRegisteringGeofence
                          ? null
                          : enabled
                          ? _continueToHome
                          : _openSettings,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: Sizes.radius16,
                        ),
                      ),
                      child: _loading || _isRegisteringGeofence
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              enabled ? 'Next' : 'Open App Settings',
                              style: TextStyles.button,
                            ),
                    ),
                  ),

                  Sizes.gapH10,

                  TextButton(
                    onPressed: _loading ? null : _refreshPermission,
                    child: const Text(
                      'Refresh permission status',
                      style: TextStyles.cyanLink,
                    ),
                  ),

                  Sizes.gapH12,
                  const Text(
                    'Location is used for workplace attendance.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSubtle,
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
