import 'package:flutter/material.dart';

class GeofenceDebug {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
  GlobalKey<ScaffoldMessengerState>();

  static void show(String message, {bool isError = false}) {
    debugPrint('GEOFENCE DEBUG: $message');

    messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
          backgroundColor: isError ? Colors.red : Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
        ),
      );
  }
}