// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'OfficeCheck';

  @override
  String get smartWorkplace => 'スマートワークプレイス';

  @override
  String get appNameOffice => 'オフィス';

  @override
  String get appNameCheck => 'チェック';

  @override
  String get yourWorkplaceInRange => '職場が、圏内に。';

  @override
  String get smartAttendanceLocationAware => 'スマート勤怠  •  位置情報対応';

  @override
  String get stayInTheLoop => '常に把握を。';

  @override
  String get letOfficeCheckRecognise =>
      'OfficeCheckが、アプリを開いたままにしなくても、出勤・退勤を自動で認識します。';

  @override
  String get preciseLocationTitle => '精密な位置情報';

  @override
  String get preciseLocationSubtitle => 'オフィスから100m以内にいるか確認します。';

  @override
  String get statusServicesOff => 'サービスオフ';

  @override
  String get statusGranted => '許可済み';

  @override
  String get statusNeeded => '要許可';

  @override
  String get backgroundAccessTitle => 'バックグラウンドアクセス';

  @override
  String get backgroundAccessSubtitle => 'スマートフォンのロック中も出退勤を検知します。';

  @override
  String get statusSetupNext => '次の設定へ';

  @override
  String get notificationsTitle => '通知';

  @override
  String get notificationsSubtitle => 'チェックイン・チェックアウトの確認通知を受け取ります。';

  @override
  String get locationAccessEnabled => '位置情報アクセス有効';

  @override
  String get enableDeviceLocation => 'デバイスの位置情報を有効にする';

  @override
  String get openAppSettings => 'アプリ設定を開く';

  @override
  String get enableLocationAccess => '位置情報アクセスを有効にする';

  @override
  String get whyBackgroundAccess => 'バックグラウンドアクセスが必要な理由は？';

  @override
  String get locationAttendanceNotice => '位置情報は職場の勤怠管理に使用されます';

  @override
  String get whyBackgroundLocationTitle => 'バックグラウンド位置情報が必要な理由';

  @override
  String get whyBackgroundLocationDesc1 =>
      'OfficeCheckは、スマートフォンのロック中やアプリが開いていない状態でもオフィスへの入退室を検知するため、バックグラウンド位置情報へのアクセスが必要です。';

  @override
  String get whyBackgroundLocationDesc2 =>
      'Androidではフォアグラウンドの位置情報とは別に設定が必要です。次のセットアップ手順で設定方法をご案内します。';

  @override
  String get gotIt => '了解';

  @override
  String get locationServicesOffError =>
      '位置情報サービスがオフになっています。デバイス設定から有効にしてください。';

  @override
  String get locationDeniedForeverError =>
      '位置情報アクセスが永続的に拒否されました。アプリ設定から有効にしてください。';

  @override
  String get locationDeniedError => 'オフィスへの到着を検知するために位置情報アクセスが必要です。';

  @override
  String get locationSetupFailedError => '位置情報のセットアップに失敗しました。もう一度お試しください。';

  @override
  String get neverMissAPrompt => '通知を見逃さない。';

  @override
  String get getGentleReminder => 'OfficeCheckがオフィスへの到着・出発を検知した際に、確認通知をお送りします。';

  @override
  String get arrivalReminderTitle => '到着リマインダー';

  @override
  String get arrivalReminderSubtitle => 'オフィスに到着したらチェックインを確認します。';

  @override
  String get departureReminderTitle => '退勤リマインダー';

  @override
  String get departureReminderSubtitle => '退勤時にチェックアウトの確認を促します。';

  @override
  String get notificationsEnabledSubtitle => '通知の許可が有効です。';

  @override
  String get notificationsRequiredSubtitle => '勤怠記録はご自身で確認・操作していただきます。';

  @override
  String get statusEnabled => '有効';

  @override
  String get statusRequired => '要設定';

  @override
  String get continueButton => '続ける';

  @override
  String get enableNotificationsButton => '通知を有効にする';

  @override
  String get continueSetupButton => 'セットアップを続ける';

  @override
  String get maybeLaterButton => '後で';

  @override
  String get confirmEveryActionNotice => 'すべての勤怠操作はご自身で確認します';

  @override
  String get notificationSetupComplete => '通知のセットアップが完了しました。';

  @override
  String get notificationsEnabledOnDevice => 'このデバイスで通知が有効になっています。';

  @override
  String get notificationBlockedMsg => '通知の許可がブロックされています。アプリ設定から有効にしてください。';

  @override
  String get notificationPromptMsg => 'OfficeCheckが勤怠の確認通知を送るために、通知が必要です。';

  @override
  String get notificationCheckFailed => '通知アクセスを確認できませんでした。もう一度お試しください。';

  @override
  String get enableNotificationsLater =>
      '通知はAndroid設定からいつでも有効にできます。有効にするまで勤怠通知が表示されない場合があります。';

  @override
  String get officeCheckSetup => 'OFFICECHECK  •  セットアップ';

  @override
  String get stayConnectedWhenAway => '離席中も\nつながり続ける。';

  @override
  String get allowBackgroundLocationDesc =>
      'スマートフォンのロック中やアプリが開いていない状態でもオフィスへの入退室を認識するため、バックグラウンド位置情報を許可してください。';

  @override
  String get backgroundLocationRowTitle => 'バックグラウンド位置情報';

  @override
  String get statusChecking => '確認中...';

  @override
  String get statusWhileUsing => '使用中のみ';

  @override
  String get statusBlocked => 'ブロック済み';

  @override
  String get statusNotEnabled => '未有効';

  @override
  String get statusUnknown => '不明';

  @override
  String get backgroundLocationInstructions =>
      'Android設定で、権限 → 位置情報 → 常に許可 を選択してください（利用可能な場合）。メニューはデバイスによって異なる場合があります。';

  @override
  String get nextButton => '次へ';

  @override
  String get refreshPermissionStatus => '権限の状態を更新';

  @override
  String get locationUsedAttendance => '位置情報は職場の勤怠管理に使用されます。';

  @override
  String get homeNavNotConnected => 'ホームナビゲーションはまだ接続されていません。';

  @override
  String get geofenceStartError => 'オフィスの監視を開始できませんでした。もう一度お試しください。';

  @override
  String get openSettingsFailed =>
      '設定を開けませんでした。デバイスの設定からOfficeCheckの権限を開いてください。';

  @override
  String get couldNotCheckPermission => '権限を確認できませんでした。もう一度お試しください。';

  @override
  String get refreshLocationTooltip => '位置情報を更新';

  @override
  String get officeProximity => 'オフィス近接状況';

  @override
  String get inRange => '圏内';

  @override
  String get statusBadge => 'ステータス';

  @override
  String get officeNotConfigured => 'オフィス未設定';

  @override
  String get insideOfficeZone => 'オフィスゾーン内です';

  @override
  String get outsideOfficeZone => 'オフィスゾーン外です';

  @override
  String get officeBoundary => 'オフィス境界';

  @override
  String get radiusMeters => '半径100m';

  @override
  String get attendanceSection => '勤怠';

  @override
  String get checkedInStatus => 'チェックイン済み';

  @override
  String get notCheckedInStatus => '未チェックイン';

  @override
  String get checkingLocation => '位置情報確認中...';

  @override
  String get checkOut => 'チェックアウト';

  @override
  String get checkIn => 'チェックイン';

  @override
  String get attendanceAfterConfigNotice => 'オフィス座標が設定されると勤怠操作が有効になります。';

  @override
  String get todaySection => '本日';

  @override
  String get freshLocationCheckNotice =>
      '最新の位置情報でオフィス境界内であることが確認された後のみ、勤怠が許可されます。';

  @override
  String get officeNotConfiguredWarning =>
      'オフィス座標がまだ設定されていません。勤怠機能を使用する前にホーム画面で設定してください。';

  @override
  String get checkInRecorded => 'このデバイスでチェックインが記録されました。';

  @override
  String get checkOutRecorded => 'このデバイスでチェックアウトが記録されました。';

  @override
  String get turnOnLocationServices => 'デバイス設定で位置情報サービスをオンにしてください。';

  @override
  String get locationPermissionRequired => '勤怠には位置情報の許可が必要です。';

  @override
  String get locationPermissionBlocked =>
      '位置情報の許可がブロックされています。アプリ設定から有効にしてください。';

  @override
  String get locationTooOld => '位置情報が古すぎます。もう一度お試しください。';

  @override
  String get mockLocationDetected => '模擬位置情報が検出されました。勤怠は記録されませんでした。';

  @override
  String get outsideBoundaryError => 'オフィス境界（100m）の外にいます。勤怠は記録されませんでした。';

  @override
  String get setOfficeCoordinates => 'ジオフェンス勤怠をテストする前に、ホーム画面でオフィス座標を設定してください。';

  @override
  String get todaySessions => '本日のアクティビティとタイムライン';

  @override
  String get todaySessionsSubtitle => '職場のチェックインと勤務時間';

  @override
  String get noAttendanceSessionsYet => '本日の勤怠記録はまだありません。';

  @override
  String get totalWorkHours => '総勤務時間';

  @override
  String get activeSession => '進行中';

  @override
  String get completedSession => '完了';

  @override
  String get autoGeofenceCheckout => 'ジオフェンスで自動チェックアウト';

  @override
  String get manualCheckout => '手動チェックアウト';

  @override
  String get ongoingSession => '勤務中';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsPreferences => '環境設定';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSubtitle => '使用する言語を選択してください';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsCheckingPermission => '権限を確認しています...';

  @override
  String get settingsNotificationsEnabled => '通知は有効です';

  @override
  String get settingsEnableAttendanceAlerts => '勤怠通知を有効にする';

  @override
  String get settingsPermissions => '権限';

  @override
  String get settingsLocationAccess => '位置情報へのアクセス';

  @override
  String get settingsLocationAccessSubtitle => '位置情報とバックグラウンドアクセスを管理します';

  @override
  String get settingsAppPermissions => 'アプリの権限';

  @override
  String get settingsAppPermissionsSubtitle => '端末の設定で権限を管理します';

  @override
  String get settingsAbout => 'アプリについて';

  @override
  String get settingsAboutApp => 'OfficeCheckについて';

  @override
  String get settingsAboutSubtitle => '従業員向け勤怠管理アプリ';

  @override
  String get settingsAppDescription => '従業員の勤怠管理とオフィスでの出退勤記録を行うアプリです。';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageJapanese => '日本語';

  @override
  String get settingsLanguageChangedEnglish => '表示言語を英語に変更しました';

  @override
  String get settingsLanguageChangedJapanese => '表示言語を日本語に変更しました';

  @override
  String get settingsLanguageChangeFailed => '言語を変更できませんでした。もう一度お試しください。';

  @override
  String get settingsRefresh => '更新';

  @override
  String get settingsOpenDeviceSettings => '端末の設定を開く';

  @override
  String get settingsNotificationsPermissionDenied =>
      '通知の権限が拒否されています。端末の設定で有効にしてください。';

  @override
  String get settingsNotificationsPermissionRequired =>
      '勤怠通知を受け取るには、通知の権限が必要です。';

  @override
  String get attendanceHistory => '出勤履歴';

  @override
  String get refresh => '更新';

  @override
  String get daily => '日別';

  @override
  String get weekly => '週別';

  @override
  String get monthly => '月別';

  @override
  String get previousPeriod => '前の期間';

  @override
  String get nextPeriod => '次の期間';

  @override
  String get tapToSelectDate => 'タップして日付を選択';

  @override
  String get selectAttendanceDate => '出勤日を選択';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get totalWorked => '合計勤務時間';

  @override
  String get daysAttended => '出勤日数';

  @override
  String get attendanceSessions => '出勤セッション数';

  @override
  String get attendanceRecords => '出勤記録';

  @override
  String get noAttendanceRecords => 'この期間の出勤記録はありません';

  @override
  String get noAttendanceRecordsHint => '別の日付や期間を選択して、保存された出勤記録を確認してください。';

  @override
  String get attendanceHistoryLoadError => '出勤履歴を読み込めませんでした。';

  @override
  String get noAttendanceSessions => '出勤セッションはありません。';

  @override
  String get inProgress => '勤務中';

  @override
  String get firstCheckIn => '最初の出勤';

  @override
  String get lastCheckOut => '最後の退勤';

  @override
  String get timeUnavailable => '--:--';

  @override
  String workDuration(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String sessionCountHint(int count) {
    return '$count件のセッション · タップして詳細を表示';
  }

  @override
  String get locationSetupTitle => '位置情報を設定';

  @override
  String get locationSetupDescription =>
      'OfficeCheckで勤務状況を確認するために、位置情報へのアクセスが必要です。';

  @override
  String get foregroundLocationTitle => '端末の位置情報';

  @override
  String get foregroundLocationDescription =>
      '端末の位置情報をオンにして、アプリの使用中に位置情報へのアクセスを許可してください。';

  @override
  String get deviceLocationOff => '端末の位置情報がオフです';

  @override
  String get permissionRequired => '権限が必要です';

  @override
  String get backgroundLocationTitle => 'バックグラウンドでの位置情報';

  @override
  String get backgroundLocationDescription =>
      'アプリを開いていないときもオフィスへの入退室を検知できるように、アプリの設定で「常に許可」を選択してください。';

  @override
  String get alwaysAllowed => '常に許可されています';

  @override
  String get backgroundMonitoringRequired => 'バックグラウンドでの監視に必要です';

  @override
  String get notificationsDescription =>
      '勤怠リマインダーや位置情報に関する通知を受け取ります。この設定は後から変更できます。';

  @override
  String get notificationsEnabled => '通知が有効です';

  @override
  String get optional => '任意';

  @override
  String get enable => '有効にする';

  @override
  String get continueToOfficeCheck => 'OfficeCheckを続ける';

  @override
  String get permissionRefreshError => '権限を確認できませんでした。もう一度お試しください。';

  @override
  String get locationEnableError => '位置情報を有効にできませんでした。アプリの設定を確認してください。';

  @override
  String get backgroundLocationError => '位置情報の設定を開けませんでした。もう一度お試しください。';

  @override
  String get continuePermissionError => '続行するには、端末の位置情報をオンにして「常に許可」を設定してください。';

  @override
  String get backgroundLocationNote =>
      'オフィスから出たことを自動的に検知するには、バックグラウンドでの位置情報の許可が必要です。通知の設定は任意です。';
}
