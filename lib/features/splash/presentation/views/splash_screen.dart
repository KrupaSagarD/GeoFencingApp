import 'package:flutter/material.dart';

import '../../../../core/contants/constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -110,
            right: -100,
            child: AppGlowCircle(
              size: 300,
              color: AppColors.blue.withValues(alpha: 0.13),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -160,
            child: AppGlowCircle(
              size: 320,
              color: AppColors.cyan.withValues(alpha: 0.07),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: AppPaddings.screenWide,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.cyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Sizes.gapW10,
                          const Text(
                            'SMART WORKPLACE',
                            style: TextStyles.brandLabel,
                          ),
                        ],
                      ),

                      const Spacer(flex: 3),

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
                        child: _buildGeofenceIllustration(),
                      ),

                      Sizes.gapH42,
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
                              text: const TextSpan(
                                style: TextStyles.heroLarge,
                                children: [
                                  TextSpan(
                                    text: 'Office',
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                  TextSpan(
                                    text: 'Check',
                                    style: TextStyle(color: AppColors.cyan),
                                  ),
                                ],
                              ),
                            ),
                            Sizes.gapH14,
                            const Text(
                              'Your workplace, in range.',
                              textAlign: TextAlign.center,
                              style: TextStyles.bodyLarge,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 3),

                      const SizedBox(
                        width: Sizes.p24,
                        height: Sizes.p24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
                        ),
                      ),

                      Sizes.gapH16,

                      const Text(
                        'SMART ATTENDANCE  •  LOCATION AWARE',
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

  Widget _buildGeofenceIllustration() {
    return SizedBox(
      width: 270,
      height: 270,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260,
            height: 260,
            decoration: Decorations.concentricCircle(
              borderColor: AppColors.blue.withValues(alpha: 0.18),
            ),
          ),

          Container(
            width: 210,
            height: 210,
            decoration: Decorations.concentricCircle(
              borderColor: AppColors.blue.withValues(alpha: 0.3),
              borderWidth: 1.2,
            ),
          ),
          Container(
            width: 158,
            height: 158,
            decoration: Decorations.concentricCircle(
              borderColor: AppColors.cyan.withValues(alpha: 0.35),
              borderWidth: 1.4,
              fillColor: AppColors.blue.withValues(alpha: 0.06),
            ),
          ),

          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.blueGradientStart,
                  AppColors.blueDark,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.4),
                  blurRadius: 42,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.white,
              size: Sizes.iconGiant,
            ),
          ),

          Positioned(
            top: 30,
            right: Sizes.p42,
            child: Container(
              width: Sizes.iconXs,
              height: Sizes.iconXs,
              decoration: BoxDecoration(
                color: AppColors.cyan,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: 0.6),
                    blurRadius: Sizes.p12,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 25,
            left: 35,
            child: Container(
              padding: AppPaddings.all9,
              decoration: BoxDecoration(
                color: AppColors.panelAlt,
                borderRadius: Sizes.radius14,
                border: Border.all(
                  color: AppColors.cyan.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.cyan,
                size: 23,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
