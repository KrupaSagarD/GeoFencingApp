import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/features/location/data/services/native_geofence_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.example.geo_fencing/geofence');
  final log = <MethodCall>[];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'registerGeofence':
          final args = methodCall.arguments as Map<dynamic, dynamic>;
          if (args['latitude'] == -999.0) {
            throw PlatformException(code: 'ERR', message: 'Invalid coordinates');
          }
          return true;
        case 'removeGeofence':
          return true;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('NativeGeofenceService Tests', () {
    test('registerGeofence invokes method channel with correct arguments and returns true on success', () async {
      final success = await NativeGeofenceService.registerGeofence(
        latitude: 12.9328,
        longitude: 77.5400,
        radiusMeters: 100.0,
      );

      expect(success, isTrue);
      expect(log, hasLength(1));
      expect(log.first.method, 'registerGeofence');
      expect(log.first.arguments, {
        'latitude': 12.9328,
        'longitude': 77.5400,
        'radius': 100.0,
      });
    });

    test('registerGeofence catches exceptions and returns false', () async {
      final success = await NativeGeofenceService.registerGeofence(
        latitude: -999.0,
        longitude: -999.0,
      );

      expect(success, isFalse);
    });

    test('removeGeofence invokes channel and returns true', () async {
      final success = await NativeGeofenceService.removeGeofence();

      expect(success, isTrue);
      expect(log, hasLength(1));
      expect(log.first.method, 'removeGeofence');
    });

    test('removeGeofence catches channel exceptions and returns false', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw PlatformException(code: 'FAIL', message: 'Failure');
      });

      final success = await NativeGeofenceService.removeGeofence();
      expect(success, isFalse);
    });
  });
}
