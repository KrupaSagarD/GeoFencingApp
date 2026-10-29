import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/contants/colors.dart';
import '../../../../core/contants/sizes.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../l10n/generated/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool _notificationsEnabled = false;
  bool _isCheckingNotifications = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotificationStatus();
    }
  }

  Future<void> _loadNotificationStatus() async {
    try {
      final status = await Permission.notification.status;

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = status.isGranted;
        _isCheckingNotifications = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to check notification permission: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isCheckingNotifications = false;
      });
    }
  }

  Future<void> _enableNotifications() async {
    try {
      final currentStatus = await Permission.notification.status;

      if (currentStatus.isPermanentlyDenied || currentStatus.isRestricted) {
        await _openDeviceSettings();
        return;
      }

      final status = await Permission.notification.request();

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = status.isGranted;
      });

      if (status.isPermanentlyDenied || status.isRestricted) {
        await _openDeviceSettings();
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to request notification permission: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _openDeviceSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(Sizes.p16),
        children: [
          _sectionTitle(context, l10n.settingsPreferences),
          _settingsCard(
            context: context,
            icon: Icons.language_rounded,
            title: l10n.settingsLanguage,
            subtitle: l10n.settingsLanguageSubtitle,
            onTap: _showLanguageOptions,
          ),
          _settingsCard(
            context: context,
            icon: Icons.notifications_active_outlined,
            title: l10n.settingsNotifications,
            subtitle: _isCheckingNotifications
                ? l10n.settingsCheckingPermission
                : _notificationsEnabled
                ? l10n.settingsNotificationsEnabled
                : l10n.settingsEnableAttendanceAlerts,
            trailing: _isCheckingNotifications
                ? const SizedBox(
                    width: Sizes.iconMd,
                    height: Sizes.iconMd,
                    child: CircularProgressIndicator(),
                  )
                : Switch(
                    value: _notificationsEnabled,
                    activeThumbColor: AppColors.blue,
                    onChanged: (enabled) {
                      if (enabled && !_notificationsEnabled) {
                        _enableNotifications();
                      } else if (!enabled && _notificationsEnabled) {
                        _openDeviceSettings();
                      }
                    },
                  ),
            onTap: _enableNotifications,
          ),
          Sizes.gapH24,
          _sectionTitle(context, l10n.settingsPermissions),
          _settingsCard(
            context: context,
            icon: Icons.location_on_outlined,
            title: l10n.settingsLocationAccess,
            subtitle: l10n.settingsLocationAccessSubtitle,
            onTap: _openDeviceSettings,
          ),
          _settingsCard(
            context: context,
            icon: Icons.settings_applications_outlined,
            title: l10n.settingsAppPermissions,
            subtitle: l10n.settingsAppPermissionsSubtitle,
            onTap: _openDeviceSettings,
          ),
          Sizes.gapH24,
          _sectionTitle(context, l10n.settingsAbout),
          _settingsCard(
            context: context,
            icon: Icons.info_outline_rounded,
            title: l10n.settingsAboutApp,
            subtitle: l10n.settingsAboutSubtitle,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l10n.settingsAboutApp,
                applicationVersion: '1.0.0',
                applicationLegalese: l10n.settingsAppDescription,
              );
            },
          ),
          Sizes.gapH16,
          Text(
            l10n.settingsAppDescription,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.p10, left: Sizes.p4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _settingsCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.panel,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: Sizes.p10),
      shape: RoundedRectangleBorder(
        borderRadius: Sizes.radius16,
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.p16, vertical: Sizes.p6),
        leading: Icon(icon, color: AppColors.blue, size: Sizes.iconXl),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
        trailing:
            trailing ??
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: Sizes.iconLg),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageOptions() {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.panel,
      shape: const RoundedRectangleBorder(borderRadius: Sizes.radiusBottomSheet),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.p20),
                  leading: const Icon(
                    Icons.language_rounded,
                    color: AppColors.blue,
                    size: Sizes.iconLg,
                  ),
                  title: Text(l10n.settingsLanguageEnglish),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _changeLanguage('en');
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.p20),
                  leading: const Icon(
                    Icons.language_rounded,
                    color: AppColors.blue,
                    size: Sizes.iconLg,
                  ),
                  title: Text(l10n.settingsLanguageJapanese),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _changeLanguage('ja');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeLanguage(String languageCode) async {
    try {
      await AppLocale.changeLocale(languageCode);

      if (!mounted) return;

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageCode == 'ja'
                ? l10n.settingsLanguageChangedJapanese
                : l10n.settingsLanguageChangedEnglish,
          ),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to change language: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).settingsLanguageChangeFailed)),
      );
    }
  }
}
