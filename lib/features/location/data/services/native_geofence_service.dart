import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeGeofenceService {
  NativeGeofenceService._();

  static const MethodChannel _channel =
      MethodChannel('com.example.geo_fencing/geofence');

  static Future<bool> registerGeofence({
    required double latitude,
    required double longitude,
    double radiusMeters = 100.0,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('registerGeofence', {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radiusMeters,
      });
      debugPrint('NativeGeofenceService: registerGeofence result: $result');
      return result ?? false;
    } catch (e) {
      debugPrint('NativeGeofenceService: Failed to register native geofence: $e');
      return false;
    }
  }

  static Future<bool> removeGeofence() async {
    try {
      final result = await _channel.invokeMethod<bool>('removeGeofence');
      debugPrint('NativeGeofenceService: removeGeofence result: $result');
      return result ?? false;
    } catch (e) {
      debugPrint('NativeGeofenceService: Failed to remove native geofence: $e');
      return false;
    }
  }
}
