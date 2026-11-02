import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/features/location/data/services/notification_service.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAndroidNotificationsPlugin extends AndroidFlutterLocalNotificationsPlugin
    with MockPlatformInterfaceMixin {
  bool requestPermissionCalled = false;
  bool showCalled = false;
  int? lastId;
  String? lastTitle;
  String? lastBody;
  String? lastPayload;

  @override
  Future<bool> initialize({
    required AndroidInitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback? onDidReceiveBackgroundNotificationResponse,
  }) async {
    return true;
  }

  @override
  Future<bool?> requestNotificationsPermission() async {
    requestPermissionCalled = true;
    return true;
  }

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    AndroidNotificationDetails? notificationDetails,
    String? payload,
  }) async {
    showCalled = true;
    lastId = id;
    lastTitle = title;
    lastBody = body;
    lastPayload = payload;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAndroidNotificationsPlugin mockPlugin;

  setUp(() {
    mockPlugin = MockAndroidNotificationsPlugin();
    FlutterLocalNotificationsPlatform.instance = mockPlugin;
  });

  group('NotificationService Tests', () {
    test('singleton instance is non-null', () {
      expect(NotificationService.instance, isNotNull);
    });

    test('initialize registers and requests permissions without throwing', () async {
      await expectLater(NotificationService.instance.initialize(), completes);
      expect(mockPlugin.requestPermissionCalled, isTrue);
    });

    test('showAutoCheckoutNotification calls show with expected parameters', () async {
      final now = DateTime(2026, 11, 2, 18, 0);
      await NotificationService.instance.showAutoCheckoutNotification(now);

      expect(mockPlugin.showCalled, isTrue);
      expect(mockPlugin.lastId, 1001);
      expect(mockPlugin.lastTitle, 'Automatic Checkout Successful');
      expect(mockPlugin.lastBody, 'You have been checked out because you left the office area.');
      expect(mockPlugin.lastPayload, now.toIso8601String());
    });
  });
}
