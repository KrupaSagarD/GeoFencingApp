import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/contants/constants.dart';
import '../../../../l10n/generated/app_localizations.dart';

class GetNotifiedScreen extends StatefulWidget {
  const GetNotifiedScreen({super.key, this.onContinue});

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
    final l10n = AppLocalizations.of(context);
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
          _message = l10n.notificationsEnabledOnDevice;
        } else if (status.isPermanentlyDenied) {
          _message = l10n.notificationBlockedMsg;
        } else {
          _message = l10n.notificationPromptMsg;
        }
      });

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = l10n.notificationCheckFailed;
      });
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  void _continue() {
    final l10n = AppLocalizations.of(context);
    if (_notificationsEnabled) {
      if (widget.onContinue != null) {
        widget.onContinue!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notificationSetupComplete)),
        );
      }
      return;
    }

    _enableNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final buttonLabel = _notificationsEnabled
        ? l10n.continueButton
        : _permanentlyDenied
        ? l10n.openAppSettings
        : l10n.enableNotificationsButton;

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
            bottom: 30,
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
                    children: [
                      const PermissionHeroIllustration(
                        centerIcon: Icons.notifications_active_rounded,
                        badgeIcon: Icons.check_rounded,
                      ),
                      Sizes.gapH32,
                      Text(
                        l10n.neverMissAPrompt,
                        textAlign: TextAlign.center,
                        style: TextStyles.headline29,
                      ),
                      Sizes.gapH20,
                      PermissionItemRow(
                        icon: Icons.login_rounded,
                        title: l10n.arrivalReminderTitle,
                        subtitle: l10n.arrivalReminderSubtitle,
                      ),
                      Sizes.gapH12,
                      PermissionItemRow(
                        icon: Icons.logout_rounded,
                        title: l10n.departureReminderTitle,
                        subtitle: l10n.departureReminderSubtitle,
                      ),
                      Sizes.gapH12,
                      PermissionItemRow(
                        icon: _notificationsEnabled
                            ? Icons.check_circle_rounded
                            : Icons.notifications_active_outlined,
                        title: l10n.notificationsTitle,
                        subtitle: _notificationsEnabled
                            ? l10n.notificationsEnabledSubtitle
                            : l10n.notificationsRequiredSubtitle,
                        trailingText: _notificationsEnabled ? l10n.statusEnabled : l10n.statusRequired,
                        isGranted: _notificationsEnabled,
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
                                  ? AppColors.successText
                                  : AppColors.errorText,
                              fontSize: 13,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      Sizes.gapH26,
                      AppPrimaryButton(
                        text: buttonLabel,
                        isLoading: _isRequesting,
                        icon: _notificationsEnabled
                            ? Icons.check_circle_outline_rounded
                            : _permanentlyDenied
                            ? Icons.settings_outlined
                            : Icons.notifications_active_rounded,
                        onPressed: _permanentlyDenied ? openAppSettings : _continue,
                      ),
                      Sizes.gapH14,
                      TextButton(
                        onPressed: _notificationsEnabled
                            ? widget.onContinue
                            : () {
                          setState(() {
                            _message = l10n.enableNotificationsLater;
                          });
                        },
                        child: Text(
                          _notificationsEnabled ? l10n.continueSetupButton : l10n.maybeLaterButton,
                          style: TextStyles.cyanLink,
                        ),
                      ),
                      Sizes.gapH18,
                      Text(
                        l10n.confirmEveryActionNotice,
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
