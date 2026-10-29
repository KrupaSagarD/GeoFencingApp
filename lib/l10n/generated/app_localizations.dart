import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OfficeCheck'**
  String get appTitle;

  /// No description provided for @smartWorkplace.
  ///
  /// In en, this message translates to:
  /// **'SMART WORKPLACE'**
  String get smartWorkplace;

  /// No description provided for @appNameOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get appNameOffice;

  /// No description provided for @appNameCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get appNameCheck;

  /// No description provided for @yourWorkplaceInRange.
  ///
  /// In en, this message translates to:
  /// **'Your workplace, in range.'**
  String get yourWorkplaceInRange;

  /// No description provided for @smartAttendanceLocationAware.
  ///
  /// In en, this message translates to:
  /// **'SMART ATTENDANCE  •  LOCATION AWARE'**
  String get smartAttendanceLocationAware;

  /// No description provided for @stayInTheLoop.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop.'**
  String get stayInTheLoop;

  /// No description provided for @letOfficeCheckRecognise.
  ///
  /// In en, this message translates to:
  /// **'Let OfficeCheck recognise your arrival and departure without keeping the app open.'**
  String get letOfficeCheckRecognise;

  /// No description provided for @preciseLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Precise location'**
  String get preciseLocationTitle;

  /// No description provided for @preciseLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check whether you are within 100 m of your office.'**
  String get preciseLocationSubtitle;

  /// No description provided for @statusServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Services off'**
  String get statusServicesOff;

  /// No description provided for @statusGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get statusGranted;

  /// No description provided for @statusNeeded.
  ///
  /// In en, this message translates to:
  /// **'Needed'**
  String get statusNeeded;

  /// No description provided for @backgroundAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Background access'**
  String get backgroundAccessTitle;

  /// No description provided for @backgroundAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Detect arrival and departure while your phone is locked.'**
  String get backgroundAccessSubtitle;

  /// No description provided for @statusSetupNext.
  ///
  /// In en, this message translates to:
  /// **'Setup next'**
  String get statusSetupNext;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive a prompt to confirm Check In or Check Out.'**
  String get notificationsSubtitle;

  /// No description provided for @locationAccessEnabled.
  ///
  /// In en, this message translates to:
  /// **'Location Access Enabled'**
  String get locationAccessEnabled;

  /// No description provided for @enableDeviceLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Device Location'**
  String get enableDeviceLocation;

  /// No description provided for @openAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open App Settings'**
  String get openAppSettings;

  /// No description provided for @enableLocationAccess.
  ///
  /// In en, this message translates to:
  /// **'Enable Location Access'**
  String get enableLocationAccess;

  /// No description provided for @whyBackgroundAccess.
  ///
  /// In en, this message translates to:
  /// **'Why do we need background access?'**
  String get whyBackgroundAccess;

  /// No description provided for @locationAttendanceNotice.
  ///
  /// In en, this message translates to:
  /// **'YOUR LOCATION IS USED FOR WORKPLACE ATTENDANCE'**
  String get locationAttendanceNotice;

  /// No description provided for @whyBackgroundLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Why background location?'**
  String get whyBackgroundLocationTitle;

  /// No description provided for @whyBackgroundLocationDesc1.
  ///
  /// In en, this message translates to:
  /// **'OfficeCheck needs background location access to detect when you enter or leave the office while your phone is locked or the app is not open.'**
  String get whyBackgroundLocationDesc1;

  /// No description provided for @whyBackgroundLocationDesc2.
  ///
  /// In en, this message translates to:
  /// **'Android handles this separately from foreground location access. We will guide you through the required settings in the next setup step.'**
  String get whyBackgroundLocationDesc2;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @locationServicesOffError.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off. Please enable them in your device settings.'**
  String get locationServicesOffError;

  /// No description provided for @locationDeniedForeverError.
  ///
  /// In en, this message translates to:
  /// **'Location access was permanently denied. Please enable it in app settings.'**
  String get locationDeniedForeverError;

  /// No description provided for @locationDeniedError.
  ///
  /// In en, this message translates to:
  /// **'Location access is needed to detect your arrival at the office.'**
  String get locationDeniedError;

  /// No description provided for @locationSetupFailedError.
  ///
  /// In en, this message translates to:
  /// **'Location setup failed. Please try again.'**
  String get locationSetupFailedError;

  /// No description provided for @neverMissAPrompt.
  ///
  /// In en, this message translates to:
  /// **'Never miss a prompt.'**
  String get neverMissAPrompt;

  /// No description provided for @getGentleReminder.
  ///
  /// In en, this message translates to:
  /// **'Get a gentle reminder when OfficeCheck detects that you arrive at or leave your workplace.'**
  String get getGentleReminder;

  /// No description provided for @arrivalReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrival reminder'**
  String get arrivalReminderTitle;

  /// No description provided for @arrivalReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your Check In when you reach the office.'**
  String get arrivalReminderSubtitle;

  /// No description provided for @departureReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Departure reminder'**
  String get departureReminderTitle;

  /// No description provided for @departureReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get prompted to confirm your Check Out when you leave.'**
  String get departureReminderSubtitle;

  /// No description provided for @notificationsEnabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is enabled.'**
  String get notificationsEnabledSubtitle;

  /// No description provided for @notificationsRequiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You stay in control and confirm attendance yourself.'**
  String get notificationsRequiredSubtitle;

  /// No description provided for @statusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get statusEnabled;

  /// No description provided for @statusRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get statusRequired;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @enableNotificationsButton.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotificationsButton;

  /// No description provided for @continueSetupButton.
  ///
  /// In en, this message translates to:
  /// **'Continue setup'**
  String get continueSetupButton;

  /// No description provided for @maybeLaterButton.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLaterButton;

  /// No description provided for @confirmEveryActionNotice.
  ///
  /// In en, this message translates to:
  /// **'YOU CONFIRM EVERY ATTENDANCE ACTION'**
  String get confirmEveryActionNotice;

  /// No description provided for @notificationSetupComplete.
  ///
  /// In en, this message translates to:
  /// **'Notification setup is complete.'**
  String get notificationSetupComplete;

  /// No description provided for @notificationsEnabledOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Notifications are enabled on this device.'**
  String get notificationsEnabledOnDevice;

  /// No description provided for @notificationBlockedMsg.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is blocked. Enable it in app settings.'**
  String get notificationBlockedMsg;

  /// No description provided for @notificationPromptMsg.
  ///
  /// In en, this message translates to:
  /// **'Notifications are needed so OfficeCheck can prompt you to confirm attendance.'**
  String get notificationPromptMsg;

  /// No description provided for @notificationCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not check notification access. Please try again.'**
  String get notificationCheckFailed;

  /// No description provided for @enableNotificationsLater.
  ///
  /// In en, this message translates to:
  /// **'You can enable notifications later in Android Settings. Attendance prompts may not appear until then.'**
  String get enableNotificationsLater;

  /// No description provided for @officeCheckSetup.
  ///
  /// In en, this message translates to:
  /// **'OFFICECHECK  •  SETUP'**
  String get officeCheckSetup;

  /// No description provided for @stayConnectedWhenAway.
  ///
  /// In en, this message translates to:
  /// **'Stay connected\nwhen you step away.'**
  String get stayConnectedWhenAway;

  /// No description provided for @allowBackgroundLocationDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow background location so OfficeCheck can recognise office entry and exit when your phone is locked or the app is not open.'**
  String get allowBackgroundLocationDesc;

  /// No description provided for @backgroundLocationRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Background location'**
  String get backgroundLocationRowTitle;

  /// No description provided for @statusChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get statusChecking;

  /// No description provided for @statusWhileUsing.
  ///
  /// In en, this message translates to:
  /// **'While using'**
  String get statusWhileUsing;

  /// No description provided for @statusBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get statusBlocked;

  /// No description provided for @statusNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Not enabled'**
  String get statusNotEnabled;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @backgroundLocationInstructions.
  ///
  /// In en, this message translates to:
  /// **'In Android Settings, select Permissions → Location → Allow all the time, if available. The exact menu may vary by device.'**
  String get backgroundLocationInstructions;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @refreshPermissionStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh permission status'**
  String get refreshPermissionStatus;

  /// No description provided for @locationUsedAttendance.
  ///
  /// In en, this message translates to:
  /// **'Location is used for workplace attendance.'**
  String get locationUsedAttendance;

  /// No description provided for @homeNavNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Home navigation is not connected yet.'**
  String get homeNavNotConnected;

  /// No description provided for @geofenceStartError.
  ///
  /// In en, this message translates to:
  /// **'Could not start office monitoring. Please try again.'**
  String get geofenceStartError;

  /// No description provided for @openSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open Settings. Please open OfficeCheck permissions from your device Settings.'**
  String get openSettingsFailed;

  /// No description provided for @couldNotCheckPermission.
  ///
  /// In en, this message translates to:
  /// **'Could not check permission. Please try again.'**
  String get couldNotCheckPermission;

  /// No description provided for @refreshLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh location'**
  String get refreshLocationTooltip;

  /// No description provided for @officeProximity.
  ///
  /// In en, this message translates to:
  /// **'OFFICE PROXIMITY'**
  String get officeProximity;

  /// No description provided for @inRange.
  ///
  /// In en, this message translates to:
  /// **'IN RANGE'**
  String get inRange;

  /// No description provided for @statusBadge.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get statusBadge;

  /// No description provided for @officeNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Office not configured'**
  String get officeNotConfigured;

  /// No description provided for @insideOfficeZone.
  ///
  /// In en, this message translates to:
  /// **'You are inside the office zone'**
  String get insideOfficeZone;

  /// No description provided for @outsideOfficeZone.
  ///
  /// In en, this message translates to:
  /// **'You are outside the office zone'**
  String get outsideOfficeZone;

  /// No description provided for @officeBoundary.
  ///
  /// In en, this message translates to:
  /// **'Office boundary'**
  String get officeBoundary;

  /// No description provided for @radiusMeters.
  ///
  /// In en, this message translates to:
  /// **'100 m radius'**
  String get radiusMeters;

  /// No description provided for @attendanceSection.
  ///
  /// In en, this message translates to:
  /// **'ATTENDANCE'**
  String get attendanceSection;

  /// No description provided for @checkedInStatus.
  ///
  /// In en, this message translates to:
  /// **'You are checked in'**
  String get checkedInStatus;

  /// No description provided for @notCheckedInStatus.
  ///
  /// In en, this message translates to:
  /// **'Not checked in yet'**
  String get notCheckedInStatus;

  /// No description provided for @checkingLocation.
  ///
  /// In en, this message translates to:
  /// **'Checking location...'**
  String get checkingLocation;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// No description provided for @attendanceAfterConfigNotice.
  ///
  /// In en, this message translates to:
  /// **'Attendance actions will be enabled after the office coordinates are configured.'**
  String get attendanceAfterConfigNotice;

  /// No description provided for @todaySection.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todaySection;

  /// No description provided for @freshLocationCheckNotice.
  ///
  /// In en, this message translates to:
  /// **'Attendance is allowed only after a fresh location check confirms you are within the office boundary.'**
  String get freshLocationCheckNotice;

  /// No description provided for @officeNotConfiguredWarning.
  ///
  /// In en, this message translates to:
  /// **'Office coordinates are not configured yet. Set them in HomeScreen before using attendance.'**
  String get officeNotConfiguredWarning;

  /// No description provided for @checkInRecorded.
  ///
  /// In en, this message translates to:
  /// **'Check In recorded on this device.'**
  String get checkInRecorded;

  /// No description provided for @checkOutRecorded.
  ///
  /// In en, this message translates to:
  /// **'Check Out recorded on this device.'**
  String get checkOutRecorded;

  /// No description provided for @turnOnLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Turn on Location Services in your device settings.'**
  String get turnOnLocationServices;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required for attendance.'**
  String get locationPermissionRequired;

  /// No description provided for @locationPermissionBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked. Enable it in app settings.'**
  String get locationPermissionBlocked;

  /// No description provided for @locationTooOld.
  ///
  /// In en, this message translates to:
  /// **'Location is too old. Please try again.'**
  String get locationTooOld;

  /// No description provided for @mockLocationDetected.
  ///
  /// In en, this message translates to:
  /// **'Mock location detected. Attendance was not recorded.'**
  String get mockLocationDetected;

  /// No description provided for @outsideBoundaryError.
  ///
  /// In en, this message translates to:
  /// **'You are outside the 100 m office boundary. Attendance was not recorded.'**
  String get outsideBoundaryError;

  /// No description provided for @setOfficeCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Set your office coordinates in HomeScreen before testing geofence attendance.'**
  String get setOfficeCoordinates;

  /// No description provided for @todaySessions.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Activity & Timeline'**
  String get todaySessions;

  /// No description provided for @todaySessionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your workplace check-ins and session durations'**
  String get todaySessionsSubtitle;

  /// No description provided for @noAttendanceSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No attendance sessions recorded yet today.'**
  String get noAttendanceSessionsYet;

  /// No description provided for @totalWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Total Work Hours'**
  String get totalWorkHours;

  /// No description provided for @activeSession.
  ///
  /// In en, this message translates to:
  /// **'Active Now'**
  String get activeSession;

  /// No description provided for @completedSession.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedSession;

  /// No description provided for @autoGeofenceCheckout.
  ///
  /// In en, this message translates to:
  /// **'Auto checked-out via geofence'**
  String get autoGeofenceCheckout;

  /// No description provided for @manualCheckout.
  ///
  /// In en, this message translates to:
  /// **'Manually checked-out'**
  String get manualCheckout;

  /// No description provided for @ongoingSession.
  ///
  /// In en, this message translates to:
  /// **'Ongoing session'**
  String get ongoingSession;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
