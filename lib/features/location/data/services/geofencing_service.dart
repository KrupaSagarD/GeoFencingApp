
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_geofencing/flutter_background_geofencing.dart';

typedef OfficeExitCallback = Future<void> Function(DateTime eventTime);

class OfficeGeofencingService {
  OfficeGeofencingService();

  final GeofencingService _service = GeofencingService();

  StreamSubscription<GeofenceEvent>? _eventSubscription;

  bool _isStarted = false;
  bool _isHandlingExit = false;
  DateTime? _lastHandledExitEvent;

  OfficeExitCallback? _onOfficeExit;

  static const String _officeRegionId = 'office';

  // Use 100 m while testing. A 50 m radius can be unreliable.
  static const double _geofenceRadiusMeters = 100;

  Future<void> start({
    required double latitude,
    required double longitude,
    required OfficeExitCallback onOfficeExit,
  }) async {
    _onOfficeExit = onOfficeExit;

    if (_isStarted) {
      debugPrint('Geofencing: already started.');
      return;
    }

    try {
      final initialized = await _service.initialize();
      debugPrint('Geofencing initialized: $initialized');

      if (!initialized) {
        throw StateError('Geofencing initialization failed.');
      }

      final hasPermissions = await _service.requestPermissions();
      debugPrint('Geofencing permissions granted: $hasPermissions');

      if (!hasPermissions) {
        throw StateError('Geofencing permissions were not granted.');
      }

      // Subscribe before registering the region.
      await _eventSubscription?.cancel();

      _eventSubscription = _service.onGeofenceEvent.listen(
            (event) {
          debugPrint(
            'GEOFENCE EVENT: '
                'type=${event.type}, '
                'region=${event.regionId}, '
                'timestamp=${event.timestamp}',
          );

          unawaited(_handleGeofenceEvent(event));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Geofence stream error: $error');
          debugPrintStack(stackTrace: stackTrace);
        },
      );

      final serviceStarted = await _service.startService(
        notificationTitle: 'OfficeCheck is active',
        notificationText: 'Monitoring the office geofence',
        enableFallbackNotifications: true,
        fallbackNotificationTitle: 'OfficeCheck location alert',
        fallbackNotificationBody:
        'A geofence event occurred near your office.',
      );

      debugPrint('Geofencing service started: $serviceStarted');

      if (!serviceStarted) {
        throw StateError('Background geofencing service failed to start.');
      }

      // Re-register the office region and check the result.
      await _service.removeGeofence(_officeRegionId);

      final registered = await _service.addGeofence(
        GeofenceRegion(
          id: _officeRegionId,
          latitude: latitude,
          longitude: longitude,
          radius: _geofenceRadiusMeters,
          data: {'name': 'Office'},
        ),
      );

      debugPrint(
        'Office geofence registration result: $registered '
            '(radius: $_geofenceRadiusMeters m)',
      );

      if (!registered) {
        throw StateError('Office geofence registration failed.');
      }

      _isStarted = true;
      debugPrint('Office geofencing startup completed.');
    } catch (error, stackTrace) {
      debugPrint('Failed to start office geofencing: $error');
      debugPrintStack(stackTrace: stackTrace);

      await _eventSubscription?.cancel();
      _eventSubscription = null;
      _onOfficeExit = null;
      _isStarted = false;

      rethrow;
    }
  }

  Future<void> _handleGeofenceEvent(GeofenceEvent event) async {
    if (event.regionId != _officeRegionId) {
      debugPrint('Ignoring event for region ${event.regionId}');
      return;
    }

    switch (event.type) {
      case GeofenceEventType.enter:
        debugPrint('Office geofence ENTER detected.');
        break;

      case GeofenceEventType.exit:
        debugPrint('Office geofence EXIT detected.');
        await _handleOfficeExit(event);
        break;

      default:
        debugPrint('Other office geofence event: ${event.type}');
    }
  }

  Future<void> _handleOfficeExit(GeofenceEvent event) async {
    final callback = _onOfficeExit;

    if (callback == null) {
      debugPrint(
        'EXIT RECEIVED, BUT CHECKOUT CALLBACK IS NOT CONFIGURED.',
      );
      return;
    }

    if (_isHandlingExit) {
      debugPrint('Duplicate exit ignored: checkout is in progress.');
      return;
    }

    if (_lastHandledExitEvent == event.timestamp) {
      debugPrint('Duplicate exit event ignored.');
      return;
    }

    _isHandlingExit = true;

    try {
      debugPrint('Running automatic checkout callback.');

      await callback(event.timestamp);

      _lastHandledExitEvent = event.timestamp;

      debugPrint('Automatic checkout callback returned successfully.');
    } catch (error, stackTrace) {
      debugPrint('AUTOMATIC CHECKOUT FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isHandlingExit = false;
    }
  }

  Future<void> stop() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;

    final stopped = await _service.stopService();
    debugPrint('Geofencing service stopped: $stopped');

    _isStarted = false;
    _isHandlingExit = false;
    _lastHandledExitEvent = null;
    _onOfficeExit = null;
  }
}
