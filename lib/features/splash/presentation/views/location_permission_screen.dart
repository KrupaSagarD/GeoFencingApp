import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/contants/colors.dart';
import '../../../../core/contants/decorations.dart';
import '../../../../core/contants/paddings.dart';
import '../../../../core/contants/reusable_widgets.dart';
import '../../../../core/contants/sizes.dart';
import '../../../../core/contants/text_styles.dart';
import 'background_location_screen.dart';
import 'get_notified_screen.dart';
import 'home_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> with WidgetsBindingObserver {
  LocationPermission? _permission;
  bool _locationServicesEnabled = false;
  bool _isRequesting = false;
  String? _errorMessage;

  bool get _hasLocationPermission => _permission == LocationPermission.whileInUse || _permission == LocationPermission.always;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);   // used to register this object as a lifecycle as a lifecycle observer
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
    } catch (e, stackTrace) {
      debugPrint('Location permission error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() {
          _errorMessage = 'Location setup failed. Please try again.';
        });
      }
    } finally {
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
      backgroundColor: AppColors.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: Sizes.radiusBottomSheet,
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: AppPaddings.bottomSheet,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_searching_rounded,
                  color: AppColors.cyan,
                  size: Sizes.iconXl,
                ),
                Sizes.gapH18,
                const Text(
                  'Why background location?',
                  style: TextStyles.titleLarge,
                ),
                Sizes.gapH12,
                const Text(
                  'OfficeCheck needs background location access '
                  'to detect when you enter or leave the office '
                  'while your phone is locked or the app is not open.',
                  style: TextStyles.bodyMedium,
                ),
                Sizes.gapH12,
                const Text(
                  'Android handles this separately from foreground '
                  'location access. We will guide you through the '
                  'required settings in the next setup step.',
                  style: TextStyles.bodyMedium,
                ),
                Sizes.gapH24,
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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -130,
            right: -110,
            child: AppGlowCircle(
              size: 200,
              color: AppColors.blue.withValues(alpha: 0.13),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -150,
            child: AppGlowCircle(
              size: 200,
              color: AppColors.cyan.withValues(alpha: 0.07),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppPaddings.screen,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: Sizes.maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildIllustration(),
                      Sizes.gapH8,

                      const Text(
                        'Stay in the loop.',
                        textAlign: TextAlign.center,
                        style: TextStyles.headline,
                      ),
                      Sizes.gapH12,
                      const Text(
                        'Let OfficeCheck recognise your arrival '
                        'and departure without keeping the app open.',
                        textAlign: TextAlign.center,
                        style: TextStyles.bodyLarge,
                      ),

                      Sizes.gapH30,

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
                      Sizes.gapH12,
                      _permissionRow(
                        icon: Icons.nightlight_round,
                        title: 'Background access',
                        subtitle:
                            'Detect arrival and departure while '
                            'your phone is locked.',
                        status: 'Setup next',
                        granted: false,
                      ),
                      Sizes.gapH12,
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
                        Sizes.gapH18,
                        AppErrorBanner(message: _errorMessage!),
                      ],

                      Sizes.gapH26,

                      SizedBox(
                        width: double.infinity,
                        height: Sizes.buttonHeight,
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
                            backgroundColor: AppColors.blue,
                            disabledBackgroundColor: AppColors.blue.withValues(alpha: 0.45),
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(borderRadius: Sizes.radius16),
                          ),
                          child: _isRequesting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
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
                                    Sizes.gapW10,
                                    Text(
                                      _hasLocationPermission && _locationServicesEnabled
                                          ? 'Location Access Enabled'
                                          : (_hasLocationPermission && !_locationServicesEnabled)
                                          ? 'Enable Device Location'
                                          : _permission == LocationPermission.deniedForever
                                          ? 'Open App Settings'
                                          : 'Enable Location Access',
                                      style: TextStyles.button,
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      Sizes.gapH16,

                      TextButton(
                        onPressed: _showBackgroundInfo,
                        child: const Text(
                          'Why do we need background access?',
                          style: TextStyles.cyanLink,
                        ),
                      ),

                      Sizes.gapH18,

                      const Text(
                        'YOUR LOCATION IS USED FOR WORKPLACE ATTENDANCE',
                        textAlign: TextAlign.center,
                        style: TextStyles.overline10,
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
            width: 154,
            height: 154,
            decoration: Decorations.concentricCircle(
              borderColor: AppColors.blue.withValues(alpha: 0.2),
            ),
          ),
          Container(
            width: 125,
            height: 125,
            decoration: Decorations.concentricCircle(
              borderColor: AppColors.cyan.withValues(alpha: 0.35),
              fillColor: AppColors.blue.withValues(alpha: 0.07),
            ),
          ),
          Container(
            width: 68,
            height: 68,
            decoration: Decorations.roundedHeroIcon,
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.white,
              size: Sizes.iconHero,
            ),
          ),
          Positioned(
            top: 18,
            right: 25,
            child: Container(
              padding: AppPaddings.all8,
              decoration: Decorations.floatingStatusBadge,
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.cyan,
                size: 21,
              ),
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
      padding: AppPaddings.card,
      decoration: Decorations.panelCard(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: Decorations.iconBox(),
            child: Icon(icon, color: AppColors.cyan, size: 23),
          ),
          Sizes.gapW13,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyles.itemTitle),
                Sizes.gapH4,
                Text(subtitle, style: TextStyles.bodySmall),
              ],
            ),
          ),
          Sizes.gapW8,
          Icon(
            granted ? Icons.check_circle : Icons.arrow_forward_ios_rounded,
            color: granted ? AppColors.cyan : AppColors.muted,
            size: granted ? 19 : 15,
          ),
        ],
      ),
    );
  }
}
