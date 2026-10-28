import 'package:flutter/material.dart';

import '../../../../core/contants/constants.dart';
import '../../../../core/localization/app_localizations.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background light glow effects
          Positioned(
            top: -110,
            right: -100,
            child: AppGlowCircle(
              size: 300,
              color: AppColors.blue.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -160,
            child: AppGlowCircle(
              size: 320,
              color: AppColors.cyan.withValues(alpha: 0.06),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: AppPaddings.screenWide,
                  child: Column(
                    children: [
                      // Brand label
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Sizes.gapW10,
                          Text(
                            l10n.smartWorkplace,
                            style: TextStyles.brandLabel,
                          ),
                        ],
                      ),

                      const Spacer(flex: 3),

                      // Animated geofence illustration
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.75, end: 1),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: const GeofenceConcentricIllustration(),
                      ),

                      Sizes.gapH42,

                      // App name
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 900),
                        builder: (context, opacity, child) {
                          return Opacity(
                            opacity: opacity,
                            child: child,
                          );
                        },
                        child: Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                style: TextStyles.heroLarge,
                                children: [
                                  TextSpan(
                                    text: l10n.appNameOffice,
                                    style: const TextStyle(color: AppColors.textPrimary),
                                  ),
                                  TextSpan(
                                    text: l10n.appNameCheck,
                                    style: const TextStyle(color: AppColors.blue),
                                  ),
                                ],
                              ),
                            ),
                            Sizes.gapH14,
                            Text(
                              l10n.yourWorkplaceInRange,
                              textAlign: TextAlign.center,
                              style: TextStyles.bodyLarge,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Loading indicator
                      const SizedBox(
                        width: Sizes.p24,
                        height: Sizes.p24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                        ),
                      ),

                      Sizes.gapH16,

                      Text(
                        l10n.smartAttendanceLocationAware,
                        textAlign: TextAlign.center,
                        style: TextStyles.overline,
                      ),

                      Sizes.gapH12,
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
