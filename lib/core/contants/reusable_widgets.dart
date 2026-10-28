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
          elevation: 2,
          shadowColor: AppColors.blue.withValues(alpha: 0.3),
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
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Reusable geofence radar concentric illustration for splash and permissions
class GeofenceConcentricIllustration extends StatelessWidget {
  const GeofenceConcentricIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      height: 270,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer geofence boundary
          Container(
            width: 260,
            height: 260,
            decoration: Decorations.concentricCircle(
              borderColor: AppColors.blue.withValues(alpha: 0.15),
            ),
          ),

          // Middle boundary
          Container(
            width: 210,
            height: 210,
            decoration: Decorations.concentricCircle(
              borderColor: AppColors.blue.withValues(alpha: 0.25),
              borderWidth: 1.2,
            ),
          ),

          // Inner boundary
          Container(
            width: 158,
            height: 158,
            decoration: Decorations.concentricCircle(
              borderColor: AppColors.cyan.withValues(alpha: 0.4),
              borderWidth: 1.4,
              fillColor: AppColors.blue.withValues(alpha: 0.05),
            ),
          ),

          // Central location icon
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
              boxShadow: const [
                BoxShadow(
                  color: Color(0x382563EB),
                  blurRadius: 36,
                  spreadRadius: 4,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.white,
              size: Sizes.iconGiant,
            ),
          ),

          // Small location signal
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
                    color: AppColors.cyan.withValues(alpha: 0.5),
                    blurRadius: Sizes.p8,
                  ),
                ],
              ),
            ),
          ),

          // Office status indicator badge
          Positioned(
            bottom: 25,
            left: 35,
            child: Container(
              padding: AppPaddings.all9,
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: Sizes.radius14,
                border: Border.all(
                  color: const Color(0xFFBFDBFE),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.blue,
                size: 23,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable small hero illustration (190x190) used across onboarding
class PermissionHeroIllustration extends StatelessWidget {
  const PermissionHeroIllustration({
    super.key,
    required this.centerIcon,
    this.badgeIcon = Icons.verified_user_rounded,
  });

  final IconData centerIcon;
  final IconData badgeIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 184,
            height: 184,
            decoration: Decorations.concentricCircle(
              borderColor: AppColors.blue.withValues(alpha: 0.15),
            ),
          ),
          Container(
            width: 145,
            height: 145,
            decoration: Decorations.concentricCircle(
              borderColor: AppColors.blue.withValues(alpha: 0.25),
              fillColor: AppColors.blue.withValues(alpha: 0.05),
            ),
          ),
          Container(
            width: 98,
            height: 98,
            decoration: Decorations.roundedHeroIcon,
            child: Icon(
              centerIcon,
              color: AppColors.white,
              size: Sizes.iconHero,
            ),
          ),
          Positioned(
            top: 18,
            right: 25,
            child: Container(
              padding: AppPaddings.all8,
              decoration: Decorations.floatingStatusBadge,
              child: Icon(
                badgeIcon,
                color: AppColors.blue,
                size: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable permission card row item
class PermissionItemRow extends StatelessWidget {
  const PermissionItemRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingText,
    this.isGranted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingText;
  final bool isGranted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.card,
      decoration: Decorations.panelCard(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: Decorations.iconBox(),
            child: Icon(icon, color: AppColors.blue, size: 23),
          ),
          Sizes.gapW13,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyles.itemTitle),
                Sizes.gapH4,
                Text(subtitle, style: TextStyles.bodySmall),
              ],
            ),
          ),
          if (trailingText != null) ...[
            Sizes.gapW8,
            Text(
              trailingText!,
              style: TextStyle(
                color: isGranted ? AppColors.blue : AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            Sizes.gapW8,
            Icon(
              isGranted ? Icons.check_circle : Icons.arrow_forward_ios_rounded,
              color: isGranted ? AppColors.blue : AppColors.muted,
              size: isGranted ? 19 : 15,
            ),
          ],
        ],
      ),
    );
  }
}

/// Reusable small status pill badge
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: Decorations.statusPill(color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 7),
          Sizes.gapW8,
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable today attendance time card
class AttendanceTimeCard extends StatelessWidget {
  const AttendanceTimeCard({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
  });

  final String title;
  final String time;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.card,
      decoration: Decorations.panelCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.blue, size: Sizes.iconMd),
          Sizes.gapH12,
          Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          Sizes.gapH4,
          Text(
            time,
            style: TextStyles.timeDisplay,
          ),
        ],
      ),
    );
  }
}

/// Reusable feedback message box
class FeedbackMessageCard extends StatelessWidget {
  const FeedbackMessageCard({
    super.key,
    required this.icon,
    required this.message,
    required this.isWarning,
  });

  final IconData icon;
  final String message;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? const Color(0xFFD97706) : AppColors.blue;

    return Container(
      padding: AppPaddings.all14,
      decoration: Decorations.messageCard(color),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          Sizes.gapW10,
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern interactive Attendance Session Timeline Card
class SessionTimelineCard extends StatelessWidget {
  const SessionTimelineCard({
    super.key,
    required this.sessionNumber,
    required this.checkInFormatted,
    required this.checkOutFormatted,
    required this.durationFormatted,
    required this.isCompleted,
    this.isAutoGeofence = false,
  });

  final int sessionNumber;
  final String checkInFormatted;
  final String checkOutFormatted;
  final String durationFormatted;
  final bool isCompleted;
  final bool isAutoGeofence;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: Sizes.radius16,
        border: Border.all(
          color: isCompleted ? AppColors.borderSubtle : const Color(0xFF93C5FD),
          width: isCompleted ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted ? AppColors.shadow : const Color(0x1A2563EB),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: AppPaddings.all16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Session # and status badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFFEFF6FF),
                    borderRadius: Sizes.radius8,
                  ),
                  child: Text(
                    'SESSION $sessionNumber',
                    style: TextStyle(
                      color: isCompleted ? AppColors.textSecondary : AppColors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFFBBF7D0)
                          : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
                        size: 13,
                        color: isCompleted ? AppColors.success : const Color(0xFFD97706),
                      ),
                      Sizes.gapW4,
                      Text(
                        isCompleted ? 'Completed' : 'Active Now',
                        style: TextStyle(
                          color: isCompleted ? AppColors.successText : const Color(0xFF92400E),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Sizes.gapH14,

            // Timeline Check-In and Check-Out Row
            Row(
              children: [
                // Check in column
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: AppPaddings.all8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: const Icon(
                          Icons.login_rounded,
                          size: 16,
                          color: AppColors.success,
                        ),
                      ),
                      Sizes.gapW8,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Check In',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Sizes.gapH4,
                          Text(
                            checkInFormatted,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow connector
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.textSubtle,
                  ),
                ),

                // Check out column
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: AppPaddings.all8,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFFFFBEB),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted
                                ? const Color(0xFFBFDBFE)
                                : const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Icon(
                          isCompleted ? Icons.logout_rounded : Icons.timelapse_rounded,
                          size: 16,
                          color: isCompleted ? AppColors.blue : const Color(0xFFD97706),
                        ),
                      ),
                      Sizes.gapW8,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Check Out',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Sizes.gapH4,
                          Text(
                            checkOutFormatted,
                            style: TextStyle(
                              color: isCompleted ? AppColors.textPrimary : const Color(0xFFD97706),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Sizes.gapH12,
            const Divider(height: 1, color: AppColors.borderSubtle),
            Sizes.gapH10,

            // Bottom session duration and trigger type tag
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppColors.muted,
                ),
                Sizes.gapW4,
                Text(
                  'Duration: $durationFormatted',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isAutoGeofence) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: Sizes.radius8,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.radar_rounded,
                          size: 12,
                          color: AppColors.blue,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Geofence Exit',
                          style: TextStyle(
                            color: AppColors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
