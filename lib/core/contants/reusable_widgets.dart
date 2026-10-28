import 'package:flutter/material.dart';
import 'colors.dart';
import 'sizes.dart';
import 'text_styles.dart';
import 'paddings.dart';
import 'decorations.dart';

/// Reusable radial background glow circle.
class AppGlowCircle extends StatelessWidget {
  const AppGlowCircle({
    super.key,
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
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

/// Reusable primary button styled with app colors, height 54, and rounded corners.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor = AppColors.blue,
  });

  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Sizes.buttonHeight,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.45),
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: Sizes.radius16,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: Sizes.iconMd),
                    Sizes.gapW10,
                  ],
                  Text(text, style: TextStyles.button),
                ],
              ),
      ),
    );
  }
}

/// Reusable error / alert banner.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPaddings.alert,
      decoration: Decorations.errorBox,
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.errorText,
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }
}
