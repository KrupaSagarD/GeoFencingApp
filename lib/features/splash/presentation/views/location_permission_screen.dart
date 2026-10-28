import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/contants/constants.dart';
import '../../../../core/localization/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
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
            _errorMessage = l10n.locationServicesOffError;
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
          _errorMessage = l10n.locationDeniedForeverError;
        });
      } else if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = l10n.locationDeniedError;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Location permission error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() {
          _errorMessage = l10n.locationSetupFailedError;
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
    final l10n = AppLocalizations.of(context);
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
                  color: AppColors.blue,
                  size: Sizes.iconXl,
                ),
                Sizes.gapH18,
                Text(
                  l10n.whyBackgroundLocationTitle,
                  style: TextStyles.titleLarge,
                ),
                Sizes.gapH12,
                Text(
                  l10n.whyBackgroundLocationDesc1,
                  style: TextStyles.bodyMedium,
                ),
                Sizes.gapH12,
                Text(
                  l10n.whyBackgroundLocationDesc2,
                  style: TextStyles.bodyMedium,
                ),
                Sizes.gapH24,
                AppPrimaryButton(
                  text: l10n.gotIt,
                  onPressed: () => Navigator.pop(context),
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
    final l10n = AppLocalizations.of(context);

    final buttonText = _hasLocationPermission && _locationServicesEnabled
        ? l10n.locationAccessEnabled
        : (_hasLocationPermission && !_locationServicesEnabled)
        ? l10n.enableDeviceLocation
        : _permission == LocationPermission.deniedForever
        ? l10n.openAppSettings
        : l10n.enableLocationAccess;

    final preciseStatus = !_locationServicesEnabled
        ? l10n.statusServicesOff
        : _hasLocationPermission
        ? l10n.statusGranted
        : l10n.statusNeeded;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -130,
            right: -110,
            child: AppGlowCircle(
              size: 300,
              color: AppColors.blue.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -150,
            child: AppGlowCircle(
              size: 300,
              color: AppColors.cyan.withValues(alpha: 0.06),
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
                      const PermissionHeroIllustration(
                        centerIcon: Icons.location_on_rounded,
                        badgeIcon: Icons.verified_user_rounded,
                      ),
                      Sizes.gapH20,

                      Text(
                        l10n.stayInTheLoop,
                        textAlign: TextAlign.center,
                        style: TextStyles.headline,
                      ),

                      Sizes.gapH20,

                      PermissionItemRow(
                        icon: Icons.my_location_rounded,
                        title: l10n.preciseLocationTitle,
                        subtitle: l10n.preciseLocationSubtitle,
                        isGranted: _hasLocationPermission && _locationServicesEnabled,
                        trailingText: preciseStatus,
                      ),
                      Sizes.gapH12,
                      PermissionItemRow(
                        icon: Icons.nightlight_round,
                        title: l10n.backgroundAccessTitle,
                        subtitle: l10n.backgroundAccessSubtitle,
                        isGranted: false,
                        trailingText: l10n.statusSetupNext,
                      ),
                      Sizes.gapH12,
                      PermissionItemRow(
                        icon: Icons.notifications_active_outlined,
                        title: l10n.notificationsTitle,
                        subtitle: l10n.notificationsSubtitle,
                        isGranted: false,
                        trailingText: l10n.statusSetupNext,
                      ),

                      if (_errorMessage != null) ...[
                        Sizes.gapH18,
                        AppErrorBanner(message: _errorMessage!),
                      ],

                      Sizes.gapH26,

                      AppPrimaryButton(
                        text: buttonText,
                        isLoading: _isRequesting,
                        icon: _hasLocationPermission && _locationServicesEnabled
                            ? Icons.check_circle_outline
                            : (_hasLocationPermission && !_locationServicesEnabled)
                            ? Icons.location_off_rounded
                            : _permission == LocationPermission.deniedForever
                            ? Icons.settings_outlined
                            : Icons.location_on_rounded,
                        onPressed: (_hasLocationPermission && _locationServicesEnabled)
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
                      ),

                      Sizes.gapH16,

                      TextButton(
                        onPressed: _showBackgroundInfo,
                        child: Text(
                          l10n.whyBackgroundAccess,
                          style: TextStyles.cyanLink,
                        ),
                      ),

                      Sizes.gapH18,

                      Text(
                        l10n.locationAttendanceNotice,
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
}
