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
}
