import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_fencing/core/contants/colors.dart';
import 'package:geo_fencing/core/geofence_debug.dart';
import 'package:geo_fencing/l10n/generated/app_localizations.dart';

Widget createLocalizedWidget({
  required Widget child,
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) {
  return ProviderScope(
    child: MaterialApp(
      scaffoldMessengerKey: GeofenceDebug.messengerKey,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme ??
          ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
          ),
      home: child,
    ),
  );
}
