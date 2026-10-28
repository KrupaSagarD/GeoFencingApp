import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// English Localizations for OfficeCheck
class AppLocalizations {
  AppLocalizations();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations();
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
  ];

  // Splash Screen
  String get appTitle => 'OfficeCheck';
  String get smartWorkplace => 'SMART WORKPLACE';
  String get appNameOffice => 'Office';
  String get appNameCheck => 'Check';
  String get yourWorkplaceInRange => 'Your workplace, in range.';
  String get smartAttendanceLocationAware => 'SMART ATTENDANCE  •  LOCATION AWARE';

  // Location Permission Screen
  String get stayInTheLoop => 'Stay in the loop.';
  String get letOfficeCheckRecognise => 'Let OfficeCheck recognise your arrival and departure without keeping the app open.';
  String get preciseLocationTitle => 'Precise location';
  String get preciseLocationSubtitle => 'Check whether you are within 150 m of your office.';
  String get statusServicesOff => 'Services off';
  String get statusGranted => 'Granted';
  String get statusNeeded => 'Needed';
  String get backgroundAccessTitle => 'Background access';
  String get backgroundAccessSubtitle => 'Detect arrival and departure while your phone is locked.';
  String get statusSetupNext => 'Setup next';
  String get notificationsTitle => 'Notifications';
  String get notificationsSubtitle => 'Receive a prompt to confirm Check In or Check Out.';
  String get locationAccessEnabled => 'Location Access Enabled';
  String get enableDeviceLocation => 'Enable Device Location';
  String get openAppSettings => 'Open App Settings';
  String get enableLocationAccess => 'Enable Location Access';
  String get whyBackgroundAccess => 'Why do we need background access?';
  String get locationAttendanceNotice => 'YOUR LOCATION IS USED FOR WORKPLACE ATTENDANCE';
  String get whyBackgroundLocationTitle => 'Why background location?';
  String get whyBackgroundLocationDesc1 => 'OfficeCheck needs background location access to detect when you enter or leave the office while your phone is locked or the app is not open.';
  String get whyBackgroundLocationDesc2 => 'Android handles this separately from foreground location access. We will guide you through the required settings in the next setup step.';
  String get gotIt => 'Got it';
  String get locationServicesOffError => 'Location services are turned off. Please enable them in your device settings.';
  String get locationDeniedForeverError => 'Location access was permanently denied. Please enable it in app settings.';
  String get locationDeniedError => 'Location access is needed to detect your arrival at the office.';
  String get locationSetupFailedError => 'Location setup failed. Please try again.';

  // Get Notified Screen
  String get neverMissAPrompt => 'Never miss a prompt.';
  String get getGentleReminder => 'Get a gentle reminder when OfficeCheck detects that you arrive at or leave your workplace.';
  String get arrivalReminderTitle => 'Arrival reminder';
  String get arrivalReminderSubtitle => 'Confirm your Check In when you reach the office.';
  String get departureReminderTitle => 'Departure reminder';
  String get departureReminderSubtitle => 'Get prompted to confirm your Check Out when you leave.';
  String get notificationsEnabledSubtitle => 'Notification permission is enabled.';
  String get notificationsRequiredSubtitle => 'You stay in control and confirm attendance yourself.';
  String get statusEnabled => 'Enabled';
  String get statusRequired => 'Required';
  String get continueButton => 'Continue';
  String get enableNotificationsButton => 'Enable Notifications';
  String get continueSetupButton => 'Continue setup';
  String get maybeLaterButton => 'Maybe later';
  String get confirmEveryActionNotice => 'YOU CONFIRM EVERY ATTENDANCE ACTION';
  String get notificationSetupComplete => 'Notification setup is complete.';
  String get notificationsEnabledOnDevice => 'Notifications are enabled on this device.';
  String get notificationBlockedMsg => 'Notification permission is blocked. Enable it in app settings.';
  String get notificationPromptMsg => 'Notifications are needed so OfficeCheck can prompt you to confirm attendance.';
  String get notificationCheckFailed => 'We could not check notification access. Please try again.';
  String get enableNotificationsLater => 'You can enable notifications later in Android Settings. Attendance prompts may not appear until then.';

  // Background Location Screen
  String get officeCheckSetup => 'OFFICECHECK  •  SETUP';
  String get stayConnectedWhenAway => 'Stay connected\nwhen you step away.';
  String get allowBackgroundLocationDesc => 'Allow background location so OfficeCheck can recognise office entry and exit when your phone is locked or the app is not open.';
  String get backgroundLocationRowTitle => 'Background location';
  String get statusChecking => 'Checking...';
  String get statusWhileUsing => 'While using';
  String get statusBlocked => 'Blocked';
  String get statusNotEnabled => 'Not enabled';
  String get statusUnknown => 'Unknown';
  String get backgroundLocationInstructions => 'In Android Settings, select Permissions → Location → Allow all the time, if available. The exact menu may vary by device.';
  String get nextButton => 'Next';
  String get refreshPermissionStatus => 'Refresh permission status';
  String get locationUsedAttendance => 'Location is used for workplace attendance.';
  String get homeNavNotConnected => 'Home navigation is not connected yet.';
  String get geofenceStartError => 'Could not start office monitoring. Please try again.';
  String get openSettingsFailed => 'Could not open Settings. Please open OfficeCheck permissions from your device Settings.';
  String get couldNotCheckPermission => 'Could not check permission. Please try again.';

  // Home Screen
  String get refreshLocationTooltip => 'Refresh location';
  String get officeProximity => 'OFFICE PROXIMITY';
  String get inRange => 'IN RANGE';
  String get statusBadge => 'STATUS';
  String get officeNotConfigured => 'Office not configured';
  String get insideOfficeZone => 'You are inside the office zone';
  String get outsideOfficeZone => 'You are outside the office zone';
  String get officeBoundary => 'Office boundary';
  String get radiusMeters => '100 m radius';
  String get attendanceSection => 'ATTENDANCE';
  String get checkedInStatus => 'You are checked in';
  String get notCheckedInStatus => 'Not checked in yet';
  String get checkingLocation => 'Checking location...';
  String get checkOut => 'Check Out';
  String get checkIn => 'Check In';
  String get attendanceAfterConfigNotice => 'Attendance actions will be enabled after the office coordinates are configured.';
  String get todaySection => 'TODAY';
  String get freshLocationCheckNotice => 'Attendance is allowed only after a fresh location check confirms you are within the office boundary.';
  String get officeNotConfiguredWarning => 'Office coordinates are not configured yet. Set them in HomeScreen before using attendance.';
  String get checkInRecorded => 'Check In recorded on this device.';
  String get checkOutRecorded => 'Check Out recorded on this device.';
  String get turnOnLocationServices => 'Turn on Location Services in your device settings.';
  String get locationPermissionRequired => 'Location permission is required for attendance.';
  String get locationPermissionBlocked => 'Location permission is blocked. Enable it in app settings.';
  String get locationTooOld => 'Location is too old. Please try again.';
  String get mockLocationDetected => 'Mock location detected. Attendance was not recorded.';
  String get outsideBoundaryError => 'You are outside the 150 m office boundary. Attendance was not recorded.';
  String get setOfficeCoordinates => 'Set your office coordinates in HomeScreen before testing geofence attendance.';

  // Today's Sessions and Activity
  String get todaySessions => "Today's Activity & Timeline";
  String get todaySessionsSubtitle => "Your workplace check-ins and session durations";
  String get noAttendanceSessionsYet => "No attendance sessions recorded yet today.";
  String get totalWorkHours => "Total Work Hours";
  String get activeSession => "Active Now";
  String get completedSession => "Completed";
  String get autoGeofenceCheckout => "Auto checked-out via geofence";
  String get manualCheckout => "Manually checked-out";
  String get ongoingSession => "Ongoing session";
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations();

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
