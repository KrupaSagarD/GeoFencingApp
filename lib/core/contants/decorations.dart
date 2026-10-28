import 'package:flutter/material.dart';
import 'colors.dart';
import 'sizes.dart';

/// Centralized application decorations - Light Theme.
class Decorations {
  Decorations._();

  /// Standard card container decoration (Light Theme).
  static BoxDecoration panelCard({
    BorderRadius? borderRadius,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: AppColors.panel,
      borderRadius: borderRadius ?? Sizes.radius18,
      border: Border.all(
        color: borderColor ?? AppColors.borderSubtle,
      ),
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    );
  }

  /// Light panel container with 16 radius.
  static final BoxDecoration panelCard16 = BoxDecoration(
    color: AppColors.panel,
    borderRadius: Sizes.radius16,
    border: Border.all(color: AppColors.borderSubtle),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  /// Light panel container with 18 radius.
  static final BoxDecoration panelCard18 = BoxDecoration(
    color: AppColors.panel,
    borderRadius: Sizes.radius18,
    border: Border.all(color: AppColors.borderSubtle),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 10,
        offset: Offset(0, 3),
      ),
    ],
  );

  /// Light panel container with 22 radius.
  static final BoxDecoration panelCard22 = BoxDecoration(
    color: AppColors.panel,
    borderRadius: Sizes.radius20,
    border: Border.all(color: AppColors.borderSubtle),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );

  /// Attendance / Proximity gradient card (Light Theme).
  static final BoxDecoration proximityCard = BoxDecoration(
    borderRadius: Sizes.radius24,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
    ),
    border: Border.all(color: const Color(0xFFBFDBFE)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x152563EB),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );

  /// Icon container decoration.
  static BoxDecoration iconBox({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: const Color(0xFFEFF6FF),
      borderRadius: borderRadius ?? Sizes.radius13,
      border: Border.all(color: const Color(0xFFDBEAFE)),
    );
  }

  /// App bar / Header icon gradient decoration.
  static final BoxDecoration headerIconGradient = BoxDecoration(
    borderRadius: Sizes.radius14,
    gradient: const LinearGradient(
      colors: [AppColors.blueGradientStart, AppColors.blueGradientEnd],
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x332563EB),
        blurRadius: 10,
        offset: Offset(0, 3),
      ),
    ],
  );

  /// Circular central hero icon gradient decoration.
  static final BoxDecoration circularHeroIcon = BoxDecoration(
    shape: BoxShape.circle,
    gradient: const LinearGradient(
      colors: [AppColors.blueGradientStart, AppColors.blueGradientEnd],
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x402563EB),
        blurRadius: 24,
        offset: Offset(0, 6),
      ),
    ],
  );

  /// Rounded rectangle illustration hero icon decoration (98x98).
  static final BoxDecoration roundedHeroIcon = BoxDecoration(
    borderRadius: Sizes.radius30,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.blueGradientStart,
        AppColors.blueGradientEnd,
      ],
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x402563EB),
        blurRadius: 28,
        offset: Offset(0, 8),
      ),
    ],
  );

  /// Verified / Status small floating circular badge decoration.
  static final BoxDecoration floatingStatusBadge = BoxDecoration(
    color: AppColors.panel,
    shape: BoxShape.circle,
    border: Border.all(color: const Color(0xFFBFDBFE)),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 6,
      ),
    ],
  );

  /// Error / Alert container box decoration.
  static final BoxDecoration errorBox = BoxDecoration(
    color: AppColors.errorBackground,
    borderRadius: Sizes.radius14,
    border: Border.all(color: AppColors.errorBorder),
  );

  /// Success / Notification container box decoration.
  static final BoxDecoration successBox = BoxDecoration(
    color: AppColors.successBackground,
    borderRadius: Sizes.radius14,
    border: Border.all(color: AppColors.successBorder),
  );

  /// Geofence boundary concentric circle decorations.
  static BoxDecoration concentricCircle({
    required Color borderColor,
    double borderWidth = 1.0,
    Color? fillColor,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: fillColor,
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
    );
  }

  /// Rounded status pill decoration (with dynamic status color).
  static BoxDecoration statusPill(Color color) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: Sizes.radius20,
    );
  }

  /// Info message card decoration (dynamic color).
  static BoxDecoration messageCard(Color color) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: Sizes.radius14,
      border: Border.all(color: color.withValues(alpha: 0.25)),
    );
  }
}

typedef AppDecorations = Decorations;
