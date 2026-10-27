
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color _background = Color(0xFF071426);
  static const Color _blue = Color(0xFF3987FF);
  static const Color _cyan = Color(0xFF54E0E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          // Background glow effects.
          Positioned(
            top: -110,
            right: -100,
            child: _glowCircle(
              size: 300,
              color: _blue.withValues(alpha: 0.13),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -160,
            child: _glowCircle(
              size: 320,
              color: _cyan.withValues(alpha: 0.07),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // Brand label.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: _cyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 9),
                          const Text(
                            'SMART WORKPLACE',
                            style: TextStyle(
                              color: Color(0xFF9BB3CE),
                              fontSize: 11,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(flex: 3),

                      // Animated geofence illustration.
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

                      const SizedBox(height: 42),

                      // App name.
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
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1.2,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Office',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: 'Check',
                                    style: TextStyle(color: _cyan),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Your workplace, in range.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFB5C5D9),
                                fontSize: 15,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Loading indicator.
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_cyan),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'SMART ATTENDANCE  •  LOCATION AWARE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF7188A5),
                          fontSize: 9,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),
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
          // Outer geofence boundary.
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _blue.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
          ),

          // Middle boundary.
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _blue.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
          ),

          // Inner boundary.
          Container(
            width: 158,
            height: 158,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _blue.withValues(alpha: 0.06),
              border: Border.all(
                color: _cyan.withValues(alpha: 0.35),
                width: 1.4,
              ),
            ),
          ),

          // Central location icon.
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF347FFF),
                  Color(0xFF1450C8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _blue.withValues(alpha: 0.4),
                  blurRadius: 42,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 64,
            ),
          ),

          // Small location signal.
          Positioned(
            top: 30,
            right: 42,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _cyan,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _cyan.withValues(alpha: 0.6),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),

          // Office status indicator.
          Positioned(
            bottom: 25,
            left: 35,
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFF102B43),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _cyan.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: _cyan,
                size: 23,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
