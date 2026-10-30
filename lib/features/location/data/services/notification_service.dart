
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const String _channelId = 'attendance_notifications';

  Future<void> initialize() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings: settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showAutoCheckoutNotification(DateTime checkoutTime) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Attendance Notifications',
      channelDescription: 'Office check-in and checkout alerts',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.status,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: 1001,
      title: 'Automatic Checkout Successful',
      body: 'You have been checked out because you left the office area.',
      notificationDetails: details,
      payload: checkoutTime.toIso8601String(),
    );
  }
}
