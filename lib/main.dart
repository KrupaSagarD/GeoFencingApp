import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/contants/colors.dart';
import 'core/localization/app_localizations.dart';
import 'features/splash/presentation/views/location_permission_screen.dart';
import 'features/splash/presentation/views/splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: OfficeCheckApp(),
    ),
  );
}

class OfficeCheckApp extends StatelessWidget {
  const OfficeCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OfficeCheck',
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.light,
          surface: AppColors.panel,
        ),
      ),
      home: const SplashGate(),
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _showPermissionScreen = false;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() {
        _showPermissionScreen = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showPermissionScreen) {
      return const LocationPermissionScreen();
    }

    return const SplashScreen();
  }
}
