// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OfficeCheck';

  @override
  String get smartWorkplace => 'SMART WORKPLACE';

  @override
  String get appNameOffice => 'Office';

  @override
  String get appNameCheck => 'Check';

  @override
  String get yourWorkplaceInRange => 'Your workplace, in range.';

  @override
  String get smartAttendanceLocationAware =>
      'SMART ATTENDANCE  •  LOCATION AWARE';

  @override
  String get stayInTheLoop => 'Stay in the loop.';

  @override
  String get letOfficeCheckRecognise =>
      'Let OfficeCheck recognise your arrival and departure without keeping the app open.';

  @override
  String get preciseLocationTitle => 'Precise location';

  @override
  String get preciseLocationSubtitle =>
      'Check whether you are within 150 m of your office.';

  @override
  String get statusServicesOff => 'Services off';

  @override
  String get statusGranted => 'Granted';

  @override
  String get statusNeeded => 'Needed';

  @override
  String get backgroundAccessTitle => 'Background access';

  @override
  String get backgroundAccessSubtitle =>
      'Detect arrival and departure while your phone is locked.';

  @override
  String get statusSetupNext => 'Setup next';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle =>
      'Receive a prompt to confirm Check In or Check Out.';

  @override
  String get locationAccessEnabled => 'Location Access Enabled';

  @override
  String get enableDeviceLocation => 'Enable Device Location';

  @override
  String get openAppSettings => 'Open App Settings';

  @override
  String get enableLocationAccess => 'Enable Location Access';

  @override
  String get whyBackgroundAccess => 'Why do we need background access?';

  @override
  String get locationAttendanceNotice =>
      'YOUR LOCATION IS USED FOR WORKPLACE ATTENDANCE';

  @override
  String get whyBackgroundLocationTitle => 'Why background location?';

  @override
  String get whyBackgroundLocationDesc1 =>
      'OfficeCheck needs background location access to detect when you enter or leave the office while your phone is locked or the app is not open.';

  @override
  String get whyBackgroundLocationDesc2 =>
      'Android handles this separately from foreground location access. We will guide you through the required settings in the next setup step.';

  @override
  String get gotIt => 'Got it';

  @override
  String get locationServicesOffError =>
      'Location services are turned off. Please enable them in your device settings.';

  @override
  String get locationDeniedForeverError =>
      'Location access was permanently denied. Please enable it in app settings.';

  @override
  String get locationDeniedError =>
      'Location access is needed to detect your arrival at the office.';

  @override
  String get locationSetupFailedError =>
      'Location setup failed. Please try again.';

  @override
  String get neverMissAPrompt => 'Never miss a prompt.';

  @override
  String get getGentleReminder =>
      'Get a gentle reminder when OfficeCheck detects that you arrive at or leave your workplace.';

  @override
  String get arrivalReminderTitle => 'Arrival reminder';

  @override
  String get arrivalReminderSubtitle =>
      'Confirm your Check In when you reach the office.';

  @override
  String get departureReminderTitle => 'Departure reminder';

  @override
  String get departureReminderSubtitle =>
      'Get prompted to confirm your Check Out when you leave.';

  @override
  String get notificationsEnabledSubtitle =>
      'Notification permission is enabled.';

  @override
  String get notificationsRequiredSubtitle =>
      'You stay in control and confirm attendance yourself.';

  @override
  String get statusEnabled => 'Enabled';

  @override
  String get statusRequired => 'Required';

  @override
  String get continueButton => 'Continue';

  @override
  String get enableNotificationsButton => 'Enable Notifications';

  @override
  String get continueSetupButton => 'Continue setup';

  @override
  String get maybeLaterButton => 'Maybe later';

  @override
  String get confirmEveryActionNotice => 'YOU CONFIRM EVERY ATTENDANCE ACTION';

  @override
  String get notificationSetupComplete => 'Notification setup is complete.';

  @override
  String get notificationsEnabledOnDevice =>
      'Notifications are enabled on this device.';

  @override
  String get notificationBlockedMsg =>
      'Notification permission is blocked. Enable it in app settings.';

  @override
  String get notificationPromptMsg =>
      'Notifications are needed so OfficeCheck can prompt you to confirm attendance.';

  @override
  String get notificationCheckFailed =>
      'We could not check notification access. Please try again.';

  @override
  String get enableNotificationsLater =>
      'You can enable notifications later in Android Settings. Attendance prompts may not appear until then.';

  @override
  String get officeCheckSetup => 'OFFICECHECK  •  SETUP';

  @override
  String get stayConnectedWhenAway => 'Stay connected\nwhen you step away.';

  @override
  String get allowBackgroundLocationDesc =>
      'Allow background location so OfficeCheck can recognise office entry and exit when your phone is locked or the app is not open.';

  @override
  String get backgroundLocationRowTitle => 'Background location';

  @override
  String get statusChecking => 'Checking...';

  @override
  String get statusWhileUsing => 'While using';

  @override
  String get statusBlocked => 'Blocked';

  @override
  String get statusNotEnabled => 'Not enabled';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get backgroundLocationInstructions =>
      'In Android Settings, select Permissions → Location → Allow all the time, if available. The exact menu may vary by device.';

  @override
  String get nextButton => 'Next';

  @override
  String get refreshPermissionStatus => 'Refresh permission status';

  @override
  String get locationUsedAttendance =>
      'Location is used for workplace attendance.';

  @override
  String get homeNavNotConnected => 'Home navigation is not connected yet.';

  @override
  String get geofenceStartError =>
      'Could not start office monitoring. Please try again.';

  @override
  String get openSettingsFailed =>
      'Could not open Settings. Please open OfficeCheck permissions from your device Settings.';

  @override
  String get couldNotCheckPermission =>
      'Could not check permission. Please try again.';

  @override
  String get refreshLocationTooltip => 'Refresh location';

  @override
  String get officeProximity => 'OFFICE PROXIMITY';

  @override
  String get inRange => 'IN RANGE';

  @override
  String get statusBadge => 'STATUS';

  @override
  String get officeNotConfigured => 'Office not configured';

  @override
  String get insideOfficeZone => 'You are inside the office zone';

  @override
  String get outsideOfficeZone => 'You are outside the office zone';

  @override
  String get officeBoundary => 'Office boundary';

  @override
  String get radiusMeters => '150 m radius';

  @override
  String get attendanceSection => 'ATTENDANCE';

  @override
  String get checkedInStatus => 'You are checked in';

  @override
  String get notCheckedInStatus => 'Not checked in yet';

  @override
  String get checkingLocation => 'Checking location...';

  @override
  String get checkOut => 'Check Out';

  @override
  String get checkIn => 'Check In';

  @override
  String get attendanceAfterConfigNotice =>
      'Attendance actions will be enabled after the office coordinates are configured.';

  @override
  String get todaySection => 'TODAY';

  @override
  String get freshLocationCheckNotice =>
      'Attendance is allowed only after a fresh location check confirms you are within the office boundary.';

  @override
  String get officeNotConfiguredWarning =>
      'Office coordinates are not configured yet. Set them in HomeScreen before using attendance.';

  @override
  String get checkInRecorded => 'Check In recorded on this device.';

  @override
  String get checkOutRecorded => 'Check Out recorded on this device.';

  @override
  String get turnOnLocationServices =>
      'Turn on Location Services in your device settings.';

  @override
  String get locationPermissionRequired =>
      'Location permission is required for attendance.';

  @override
  String get locationPermissionBlocked =>
      'Location permission is blocked. Enable it in app settings.';

  @override
  String get locationTooOld => 'Location is too old. Please try again.';

  @override
  String get mockLocationDetected =>
      'Mock location detected. Attendance was not recorded.';

  @override
  String get outsideBoundaryError =>
      'You are outside the 150 m office boundary. Attendance was not recorded.';

  @override
  String get setOfficeCoordinates =>
      'Set your office coordinates in HomeScreen before testing geofence attendance.';

  @override
  String get todaySessions => 'Today\'s Activity & Timeline';

  @override
  String get todaySessionsSubtitle =>
      'Your workplace check-ins and session durations';

  @override
  String get noAttendanceSessionsYet =>
      'No attendance sessions recorded yet today.';

  @override
  String get totalWorkHours => 'Total Work Hours';

  @override
  String get activeSession => 'Active Now';

  @override
  String get completedSession => 'Completed';

  @override
  String get autoGeofenceCheckout => 'Auto checked-out via geofence';

  @override
  String get manualCheckout => 'Manually checked-out';

  @override
  String get ongoingSession => 'Ongoing session';
}
