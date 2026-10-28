import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/contants/constants.dart';

class GetNotifiedScreen extends StatefulWidget {
  const GetNotifiedScreen({super.key, this.onContinue});

  /// Called after notification setup when the app is ready to move forward.
  /// Connect this to the next onboarding screen when it is available.
  final VoidCallback? onContinue;

  @override
  State<GetNotifiedScreen> createState() => _GetNotifiedScreenState();
}

class _GetNotifiedScreenState extends State<GetNotifiedScreen>
    with WidgetsBindingObserver {
  PermissionStatus? _notificationStatus;
  bool _isRequesting = false;
  String? _message;

  bool get _notificationsEnabled => _notificationStatus?.isGranted ?? false;
  bool get _permanentlyDenied =>
      _notificationStatus?.isPermanentlyDenied ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNotificationStatus();
    }
  }

  Future<void> _refreshNotificationStatus() async {
    final status = await Permission.notification.status;
    if (!mounted) return;

    setState(() {
      _notificationStatus = status;
      if (status.isGranted) _message = null;
    });
  }

  Future<void> _enableNotifications() async {
    setState(() {
      _isRequesting = true;
      _message = null;
    });

    try {
      var status = await Permission.notification.status;
      if (!status.isGranted && !status.isPermanentlyDenied) {
        status = await Permission.notification.request();
      }

      if (!mounted) return;
      setState(() {
        _notificationStatus = status;
        if (status.isGranted) {
          _message = 'Notifications are enabled on this device.';
        } else if (status.isPermanentlyDenied) {
          _message =
          'Notification permission is blocked. Enable it in app settings.';
        } else {
          _message =
          'Notifications are needed so OfficeCheck can prompt you to confirm attendance.';
        }
      });

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'We could not check notification access. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  void _continue() {
    if (_notificationsEnabled) {
      if (widget.onContinue != null) {
        widget.onContinue!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification setup is complete.')),
        );
      }
      return;
    }

    _enableNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final buttonLabel = _notificationsEnabled
        ? 'Continue'
        : _permanentlyDenied
        ? 'Open App Settings'
        : 'Enable Notifications';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -130,
            right: -110,
            child: AppGlowCircle(
              size: 300,
              color: AppColors.blue.withValues(alpha: 0.13),
            ),
          ),
          Positioned(
            bottom: 30,
            left: -150,
            child: AppGlowCircle(
              size: 300,
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
                    children: [
                      _buildIllustration(),
                      Sizes.gapH8,
                      const Text(
                        'Never miss a Notification.',
                        textAlign: TextAlign.center,
                        style: TextStyles.headline29,
                      ),
                      Sizes.gapH12,
                      const Text(
                        'Get a gentle reminder when OfficeCheck detects that you arrive at or leave your workplace.',
                        textAlign: TextAlign.center,
                        style: TextStyles.bodyLarge,
                      ),
                      Sizes.gapH30,
                      _infoRow(
                        icon: Icons.login_rounded,
                        title: 'Arrival reminder',
                        subtitle: 'Confirm your Check In when you reach the office.',
                      ),
                      Sizes.gapH12,
                      _infoRow(
                        icon: Icons.logout_rounded,
                        title: 'Departure reminder',
                        subtitle: 'Get prompted to confirm your Check Out when you leave.',
                      ),
                      Sizes.gapH12,
                      _infoRow(
                        icon: _notificationsEnabled
                            ? Icons.check_circle_rounded
                            : Icons.notifications_active_outlined,
                        title: 'Notifications',
                        subtitle: _notificationsEnabled
                            ? 'Notification permission is enabled.'
                            : 'You stay in control and confirm attendance yourself.',
                        trailing: _notificationsEnabled ? 'Enabled' : 'Required',
                        enabled: _notificationsEnabled,
                      ),
                      if (_message != null) ...[
                        Sizes.gapH18,
                        Container(
                          width: double.infinity,
                          padding: AppPaddings.alert,
                          decoration: _notificationsEnabled
                              ? Decorations.successBox
                              : Decorations.errorBox,
                          child: Text(
                            _message!,
                            style: TextStyle(
                              color: _notificationsEnabled
                                  ? AppColors.cyan
                                  : AppColors.errorText,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                      Sizes.gapH26,
                      SizedBox(
                        width: double.infinity,
                        height: Sizes.buttonHeight,
                        child: FilledButton(
                          onPressed: _isRequesting
                              ? null
                              : _permanentlyDenied
                              ? openAppSettings
                              : _continue,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            disabledBackgroundColor:
                            AppColors.blue.withValues(alpha: 0.45),
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: Sizes.radius16,
                            ),
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
                                _notificationsEnabled
                                    ? Icons.check_circle_outline_rounded
                                    : _permanentlyDenied
                                    ? Icons.settings_outlined
                                    : Icons.notifications_active_rounded,
                              ),
                              Sizes.gapW10,
                              Text(
                                buttonLabel,
                                style: TextStyles.button,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Sizes.gapH14,
                      TextButton(
                        onPressed: _notificationsEnabled
                            ? widget.onContinue
                            : () {
                          setState(() {
                            _message =
                            'You can enable notifications later in Android Settings. Attendance prompts may not appear until then.';
                          });
                        },
                        child: Text(
                          _notificationsEnabled ? 'Continue setup' : 'Maybe later',
                          style: TextStyles.cyanLink,
                        ),
                      ),
                      Sizes.gapH18,
                      const Text(
                        'YOU CONFIRM EVERY ATTENDANCE ACTION',
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
              Icons.notifications_active_rounded,
              color: AppColors.white,
              size: 48,
            ),
          ),
          Positioned(
            top: 18,
            right: 25,
            child: Container(
              padding: AppPaddings.all8,
              decoration: Decorations.floatingStatusBadge,
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.cyan,
                size: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailing,
    bool enabled = false,
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
                Text(
                  title,
                  style: TextStyles.itemTitle,
                ),
                Sizes.gapH4,
                Text(
                  subtitle,
                  style: TextStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            Sizes.gapW8,
            Text(
              trailing,
              style: TextStyle(
                color: enabled ? AppColors.cyan : AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
