import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing/core/localization/app_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppLocale', () {
    test('default locale is English (en)', () {
      expect(AppLocale.locale.value, const Locale('en'));
    });

    test('loadSavedLocale defaults to en if no preference is saved', () async {
      SharedPreferences.setMockInitialValues({});
      await AppLocale.loadSavedLocale();
      expect(AppLocale.locale.value, const Locale('en'));
    });

    test('loadSavedLocale loads ja if saved preference is ja', () async {
      SharedPreferences.setMockInitialValues({
        'officecheck_app_locale': 'ja',
      });
      await AppLocale.loadSavedLocale();
      expect(AppLocale.locale.value, const Locale('ja'));
    });

    test('changeLocale updates locale and persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      await AppLocale.changeLocale('ja');
      expect(AppLocale.locale.value, const Locale('ja'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('officecheck_app_locale'), 'ja');

      await AppLocale.changeLocale('en');
      expect(AppLocale.locale.value, const Locale('en'));
      expect(prefs.getString('officecheck_app_locale'), 'en');
    });

    test('changeLocale ignores unsupported language codes', () async {
      await AppLocale.changeLocale('en');
      expect(AppLocale.locale.value, const Locale('en'));

      await AppLocale.changeLocale('fr');
      expect(AppLocale.locale.value, const Locale('en'));

      await AppLocale.changeLocale('es');
      expect(AppLocale.locale.value, const Locale('en'));
    });
  });
}
