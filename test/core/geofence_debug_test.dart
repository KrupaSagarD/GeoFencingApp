import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/core/geofence_debug.dart';

void main() {
  test('GeofenceDebug.show executes without error when no ScaffoldMessenger is attached', () {
    expect(() => GeofenceDebug.show('Test message 1'), returnsNormally);
    expect(() => GeofenceDebug.show('Error message 1', isError: true), returnsNormally);
  });

  testWidgets('GeofenceDebug.show shows regular SnackBar when ScaffoldMessenger is mounted', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: GeofenceDebug.messengerKey,
        home: const Scaffold(
          body: Center(child: Text('Home')),
        ),
      ),
    );

    GeofenceDebug.show('Office Area Reached');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Office Area Reached'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('GeofenceDebug.show shows error SnackBar with red background', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: GeofenceDebug.messengerKey,
        home: const Scaffold(
          body: Center(child: Text('Home')),
        ),
      ),
    );

    GeofenceDebug.show('Geofence Error Occurred', isError: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Geofence Error Occurred'), findsOneWidget);
  });
}
