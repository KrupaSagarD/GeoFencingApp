import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
  static const Color _background = Color(0xFF071426);
  static const Color _blue = Color(0xFF3987FF);
  static const Color _cyan = Color(0xFF54E0E8);
  static const Color _muted = Color(0xFF9BB0C9);

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
      backgroundColor: _background,
      body: Stack(
        children: [
          Positioned(
            top: -130,
            right: -110,
            child: _glow(300, _blue.withValues(alpha: 0.13)),
          ),
          Positioned(
            bottom: 30,
            left: -150,
            child: _glow(300, _cyan.withValues(alpha: 0.07)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      _buildIllustration(),
                      const SizedBox(height: 32),
                      const Text(
                        'Never miss a prompt.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 29,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Get a gentle reminder when OfficeCheck detects that you arrive at or leave your workplace.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _muted,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _infoRow(
                        icon: Icons.login_rounded,
                        title: 'Arrival reminder',
                        subtitle: 'Confirm your Check In when you reach the office.',
                      ),
                      const SizedBox(height: 12),
                      _infoRow(
                        icon: Icons.logout_rounded,
                        title: 'Departure reminder',
                        subtitle: 'Get prompted to confirm your Check Out when you leave.',
                      ),
                      const SizedBox(height: 12),
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
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _notificationsEnabled
                                ? const Color(0xFF123A3D)
                                : const Color(0xFF451F2B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _notificationsEnabled
                                  ? _cyan.withValues(alpha: 0.4)
                                  : const Color(0xFF8E3D4B),
                            ),
                          ),
                          child: Text(
                            _message!,
                            style: TextStyle(
                              color: _notificationsEnabled
                                  ? _cyan
                                  : const Color(0xFFFFC3CC),
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
                              : _permanentlyDenied
                              ? openAppSettings
                              : _continue,
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            disabledBackgroundColor:
                            _blue.withValues(alpha: 0.45),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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
                                _notificationsEnabled
                                    ? Icons.check_circle_outline_rounded
                                    : _permanentlyDenied
                                    ? Icons.settings_outlined
                                    : Icons.notifications_active_rounded,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                buttonLabel,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
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
                          style: const TextStyle(
                            color: _cyan,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'YOU CONFIRM EVERY ATTENDANCE ACTION',
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
                BoxShadow(
                  color: _blue.withValues(alpha: 0.3),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 48,
            ),
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
              child: const Icon(
                Icons.check_rounded,
                color: _cyan,
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
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(
              trailing,
              style: TextStyle(
                color: enabled ? _cyan : _muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
