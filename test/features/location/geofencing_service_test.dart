import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/features/location/data/services/geofencing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfficeGeofencingService Tests', () {
    test('singleton instance is consistent', () {
      final s1 = OfficeGeofencingService.instance;
      final s2 = OfficeGeofencingService();
      expect(identical(s1, s2), isTrue);
    });

    test('initial state and resetExitState behave safely', () {
      final service = OfficeGeofencingService.instance;
      expect(() => service.resetExitState(), returnsNormally);
      expect(service.isStarted, isA<bool>());
    });
  });
}
