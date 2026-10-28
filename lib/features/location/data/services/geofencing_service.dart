
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_geofencing/flutter_background_geofencing.dart';

class OfficeGeofencingService {
  OfficeGeofencingService();

  final GeofencingService _service = GeofencingService();

  StreamSubscription<GeofenceEvent>? _eventSubscription;

  bool _isStarted = false;

  static const String _officeRegionId = 'office';
  static const double _geofenceRadiusMeters = 50;

  Future<void> start({
    required double latitude,
    required double longitude,
  }) async {
    if (_isStarted) {
      debugPrint('Office geofencing is already started.');
      return;
    }

    try {
      await _service.initialize();
      await _service.requestPermissions();

      _eventSubscription ??= _service.onGeofenceEvent.listen(
        _handleGeofenceEvent,
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Geofence event stream error: $error');
        },
      );

      await _service.startService(
        notificationTitle: 'OfficeCheck is active',
        notificationText: 'Monitoring the office geofence',
      );

      await _service.addGeofence(
        GeofenceRegion(
          id: _officeRegionId,
          latitude: latitude,
          longitude: longitude,
          radius: _geofenceRadiusMeters,
          data: {'name': 'Office'},
        ),
      );

      _isStarted = true;
      debugPrint('Office geofence registered successfully.');
    } catch (error, stackTrace) {
      debugPrint('Failed to start office geofencing: $error');
      debugPrintStack(stackTrace: stackTrace);

      await _eventSubscription?.cancel();
      _eventSubscription = null;

      rethrow;
    }
  }

  void _handleGeofenceEvent(GeofenceEvent event) {
    if (event.regionId != _officeRegionId) return;

    switch (event.type) {
      case GeofenceEventType.enter:
        debugPrint('Office geofence entered.');
        break;

      case GeofenceEventType.exit:
        debugPrint('Office geofence exited.');
        break;

      default:
        debugPrint('Office geofence event: ${event.type}');
    }
  }

  Future<void> stop() async {
    try {
      await _eventSubscription?.cancel();
      _eventSubscription = null;

      await _service.stopService();
      _isStarted = false;

      debugPrint('Office geofencing stopped.');
    } catch (error, stackTrace) {
      debugPrint('Failed to stop office geofencing: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
