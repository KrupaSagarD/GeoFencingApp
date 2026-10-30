import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_geofencing/flutter_background_geofencing.dart';

import '../../../../core/geofence_debug.dart';
import 'notification_service.dart';

typedef OfficeExitCallback = Future<bool> Function(DateTime eventTime);

class OfficeGeofencingService {
  OfficeGeofencingService._internal();
  static final OfficeGeofencingService instance = OfficeGeofencingService._internal();
  factory OfficeGeofencingService() => instance;

  final GeofencingService _service = GeofencingService();

  StreamSubscription<GeofenceEvent>? _eventSubscription;

  bool _isStarted = false;
  bool _isHandlingExit = false;
  DateTime? _lastHandledExitEvent;

  OfficeExitCallback? _onOfficeExit;

  static const String _officeRegionId = 'office';

  // Use 100 m while testing. A 50 m radius can be unreliable.
  static const double _geofenceRadiusMeters = 100;

  bool get isStarted => _isStarted;

  void resetExitState() {
    _isHandlingExit = false;
    _lastHandledExitEvent = null;
    debugPrint('OfficeGeofencingService: Exit state reset');
  }

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
      GeofenceDebug.show(
        initialized
            ? '1/5: Geofencing initialized'
            : 'ERROR: Geofencing initialization failed',
        isError: !initialized,
      );
      debugPrint('Geofencing initialized: $initialized');

      if (!initialized) {
        throw StateError('Geofencing initialization failed.');
      }

      final hasPermissions = await _service.requestPermissions();

      GeofenceDebug.show(
        hasPermissions
            ? '2/5: Geofencing permissions granted'
            : 'ERROR: Geofencing permissions denied',
        isError: !hasPermissions,
      );
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

      // Re-register the office region BEFORE starting the service so native GeofencingClient has regions immediately.
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
      GeofenceDebug.show(
        registered
            ? '3/5: Office geofence registered (100m)'
            : 'ERROR: Office geofence registration failed',
        isError: !registered,
      );

      debugPrint(
        'Office geofence registration result: $registered '
        '(radius: $_geofenceRadiusMeters m)',
      );

      if (!registered) {
        throw StateError('Office geofence registration failed.');
      }

      final serviceStarted = await _service.startService(
        notificationTitle: 'OfficeCheck is active',
        notificationText: 'Monitoring the office geofence',
        enableFallbackNotifications: true,
        fallbackNotificationTitle: 'OfficeCheck location alert',
        fallbackNotificationBody: 'A geofence event occurred near your office.',
      );

      GeofenceDebug.show(
        serviceStarted
            ? '4/5: Background geofencing service started'
            : 'ERROR: Background service failed to start',
        isError: !serviceStarted,
      );

      debugPrint('Geofencing service started: $serviceStarted');

      if (!serviceStarted) {
        throw StateError('Background geofencing service failed to start.');
      }

      _isStarted = true;
      GeofenceDebug.show('5/5: OfficeCheck geofencing is ACTIVE');
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
        GeofenceDebug.show('ENTER: You entered the office area');
        resetExitState();
        break;

      case GeofenceEventType.exit:
        GeofenceDebug.show('EXIT: You left the office area');
        await _handleOfficeExit(event);
        break;

      default:
        GeofenceDebug.show('Other geofence event: ${event.type}');
    }
  }

  Future<void> _handleOfficeExit(GeofenceEvent event) async {
    final callback = _onOfficeExit;

    if (callback == null) {
      GeofenceDebug.show(
        'ERROR: Checkout callback is not configured',
        isError: true,
      );
      return;
    }

    if (_isHandlingExit) {
      GeofenceDebug.show('Duplicate EXIT ignored: checkout is processing');
      return;
    }

    if (_lastHandledExitEvent != null && _lastHandledExitEvent == event.timestamp) {
      GeofenceDebug.show('Duplicate EXIT event ignored');
      return;
    }

    _isHandlingExit = true;

    try {
      GeofenceDebug.show('Checkout triggered. Processing attendance...');

      final success = await callback(event.timestamp)
          .timeout(const Duration(seconds: 10), onTimeout: () => false);

      if (success) {
        _lastHandledExitEvent = event.timestamp;

        await NotificationService.instance.showAutoCheckoutNotification(
          event.timestamp,
        );

        GeofenceDebug.show(
          'SUCCESS: Automatic checkout saved and notification sent!',
        );
      } else {
        GeofenceDebug.show(
          'FAILED: No active attendance session or save failed',
          isError: true,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('AUTOMATIC CHECKOUT FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);

      GeofenceDebug.show(
        'Checkout error: $error',
        isError: true,
      );
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
