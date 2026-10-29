import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/contants/constants.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../location/data/services/attendance_service.dart';
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

class _BackgroundLocationScreenState extends State<BackgroundLocationScreen>
    with WidgetsBindingObserver {
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

  Future<void> _refreshPermission() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final permission = await Geolocator.checkPermission().timeout(
        const Duration(seconds: 3),
        onTimeout: () => LocationPermission.denied,
      );

      if (!mounted) return;

      setState(() {
        _permission = permission;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).couldNotCheckPermission;
      });

      debugPrint('Background permission check failed: $e');
    }
  }

  Future<void> _openSettings() async {
    final l10n = AppLocalizations.of(context);
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = l10n.openSettingsFailed;
      });

      debugPrint('Opening app settings failed: $e');
    }
  }

  Future<void> _handleOfficeExit(DateTime eventTime) async {
    debugPrint('BackgroundLocationScreen: geofence exit at $eventTime → auto checkout');
    final success = await AttendanceService.autoCheckout(eventTime);
    debugPrint('AttendanceService.autoCheckout result: $success');
  }

  void _continueToHome() {
    final l10n = AppLocalizations.of(context);

    // Immediately navigate to HomeScreen first so user experiences instant transition
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.homeNavNotConnected),
        ),
      );
    }

    _geofencingService.start(
      latitude: _officeLatitude,
      longitude: _officeLongitude,
      onOfficeExit: _handleOfficeExit,
    ).catchError((Object error, StackTrace stackTrace) {
      debugPrint('Background geofence registration error: $error');
      debugPrintStack(stackTrace: stackTrace);
    });
  }

  String _getStatus(AppLocalizations l10n) {
    if (_loading) return l10n.statusChecking;

    if (_permission == LocationPermission.always) {
      return l10n.statusEnabled;
    }

    if (_permission == LocationPermission.whileInUse) {
      return l10n.statusWhileUsing;
    }

    if (_permission == LocationPermission.deniedForever) {
      return l10n.statusBlocked;
    }

    if (_permission == LocationPermission.denied) {
      return l10n.statusNotEnabled;
    }

    return l10n.statusUnknown;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  Text(
                    l10n.officeCheckSetup,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Sizes.gapH32,
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: Decorations.concentricCircle(
                        borderColor: const Color(0xFFBFDBFE),
                        fillColor: const Color(0xFFEFF6FF),
                      ),
                      child: Icon(
                        enabled
                            ? Icons.verified_user_rounded
                            : Icons.location_on_rounded,
                        size: 60,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                  Sizes.gapH30,
                  Text(
                    l10n.stayConnectedWhenAway,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 29,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Sizes.gapH14,
                  Text(
                    l10n.allowBackgroundLocationDesc,
                    textAlign: TextAlign.center,
                    style: TextStyles.bodyMedium,
                  ),
                  Sizes.gapH28,

                  // Background permission status
                  Container(
                    padding: AppPaddings.all16,
                    decoration: Decorations.panelCard18,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          color: AppColors.blue,
                          size: 28,
                        ),
                        Sizes.gapW16,
                        Expanded(
                          child: Text(
                            l10n.backgroundLocationRowTitle,
                            style: TextStyles.itemTitle,
                          ),
                        ),
                        Sizes.gapW8,
                        Flexible(
                          child: Text(
                            _getStatus(l10n),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: enabled ? AppColors.blue : AppColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                    child: Text(
                      l10n.backgroundLocationInstructions,
                      style: const TextStyle(
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

                  // Main action
                  AppPrimaryButton(
                    text: l10n.nextButton,
                    isLoading: false,
                    onPressed: _continueToHome,
                  ),

                  Sizes.gapH10,

                  if (!enabled && !_loading) ...[
                    TextButton.icon(
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings_outlined, size: 16),
                      label: Text(
                        l10n.openAppSettings,
                        style: TextStyles.cyanLink,
                      ),
                    ),
                    Sizes.gapH4,
                  ],

                  // Refresh status
                  TextButton(
                    onPressed: _loading ? null : _refreshPermission,
                    child: Text(
                      l10n.refreshPermissionStatus,
                      style: TextStyles.cyanLink,
                    ),
                  ),

                  Sizes.gapH12,
                  Text(
                    l10n.locationUsedAttendance,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
