import 'package:flutter/material.dart';
import 'colors.dart';
import 'sizes.dart';

/// Centralized application decorations.
/// Usable anywhere as [Decorations.panelCard] or [AppDecorations.panelCard].
class Decorations {
  Decorations._();

  /// Standard dark panel container decoration (used in rows, cards, containers).
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
    );
  }

  /// Dark panel container with 16 radius.
  static final BoxDecoration panelCard16 = BoxDecoration(
    color: AppColors.panel,
    borderRadius: Sizes.radius16,
  );

  /// Dark panel container with 18 radius.
  static final BoxDecoration panelCard18 = BoxDecoration(
    color: AppColors.panel,
    borderRadius: Sizes.radius18,
  );

  /// Dark panel container with 22 radius.
  static final BoxDecoration panelCard22 = BoxDecoration(
    color: AppColors.panel,
    borderRadius: Sizes.radius20,
    border: Border.all(color: AppColors.borderSubtle),
  );

  /// Attendance / Proximity gradient card.
  static final BoxDecoration proximityCard = BoxDecoration(
    borderRadius: Sizes.radius24,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF14345A), Color(0xFF0D2038)],
    ),
    border: Border.all(color: AppColors.blue.withValues(alpha: 0.35)),
  );

  /// Blue icon container decoration (with 0.13 opacity blue fill).
  static BoxDecoration iconBox({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: AppColors.blue.withValues(alpha: 0.13),
      borderRadius: borderRadius ?? Sizes.radius13,
    );
  }

  /// App bar / Header icon gradient decoration.
  static final BoxDecoration headerIconGradient = BoxDecoration(
    borderRadius: Sizes.radius14,
    gradient: const LinearGradient(
      colors: [AppColors.blue, AppColors.blueGradientEnd],
    ),
  );

  /// Circular central hero icon gradient decoration.
  static final BoxDecoration circularHeroIcon = BoxDecoration(
    shape: BoxShape.circle,
    gradient: const LinearGradient(
      colors: [AppColors.blue, AppColors.blueGradientEnd],
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.blue.withValues(alpha: 0.28),
        blurRadius: 24,
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
        AppColors.blue,
        AppColors.blueGradientEnd,
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.blue.withValues(alpha: 0.3),
        blurRadius: 32,
        spreadRadius: 2,
      ),
    ],
  );

  /// Verified / Status small floating circular badge decoration.
  static final BoxDecoration floatingStatusBadge = BoxDecoration(
    color: AppColors.panelAlt,
    shape: BoxShape.circle,
    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
  );

  /// Error / Alert container box decoration.
  static final BoxDecoration errorBox = BoxDecoration(
    color: AppColors.errorBackground,
    borderRadius: Sizes.radius14,
    border: Border.all(color: AppColors.errorBorder),
  );

  /// Success / Notification container box decoration.
  static final BoxDecoration successBox = BoxDecoration(
    color: const Color(0xFF123A3D),
    borderRadius: Sizes.radius14,
    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
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
