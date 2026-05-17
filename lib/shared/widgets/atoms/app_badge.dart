import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

enum AppBadgeTone {
  neutral,
  primary,
  success,
  warning,
  danger,
  accent,
}

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.tone = AppBadgeTone.neutral,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final IconData? icon;
  final AppBadgeTone tone;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = _toneColors(scheme);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.$1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor ?? colors.$3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foregroundColor ?? colors.$2),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foregroundColor ?? colors.$2,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) _toneColors(ColorScheme scheme) => switch (tone) {
        AppBadgeTone.primary => (
            scheme.primaryContainer.withValues(alpha: 0.92),
            scheme.primary,
            scheme.primary.withValues(alpha: 0.14),
          ),
        AppBadgeTone.success => (
            AppColors.success.withValues(alpha: 0.12),
            AppColors.success,
            AppColors.success.withValues(alpha: 0.22),
          ),
        AppBadgeTone.warning => (
            AppColors.warning.withValues(alpha: 0.12),
            AppColors.warning,
            AppColors.warning.withValues(alpha: 0.2),
          ),
        AppBadgeTone.danger => (
            AppColors.danger.withValues(alpha: 0.12),
            AppColors.danger,
            AppColors.danger.withValues(alpha: 0.18),
          ),
        AppBadgeTone.accent => (
            AppColors.brand.withValues(alpha: 0.10),
            AppColors.brand,
            AppColors.brand.withValues(alpha: 0.20),
          ),
        AppBadgeTone.neutral => (
            scheme.surfaceContainerLow.withValues(alpha: 0.9),
            scheme.onSurfaceVariant,
            scheme.outlineVariant.withValues(alpha: 0.78),
          ),
      };
}
