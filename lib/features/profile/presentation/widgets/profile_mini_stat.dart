import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';

class ProfileMiniStat extends StatelessWidget {
  const ProfileMiniStat({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.hint,
  });

  final IconData icon;
  final String title;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: isDark ? scheme.surface : Colors.white,
        border: Border.all(
          color: isDark
              ? scheme.outline.withValues(alpha: 0.35)
              : const Color(0xFFE8EDF6),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: isDark ? 0.30 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: scheme.primary.withValues(alpha: 0.13),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.22),
              ),
            ),
            child: Icon(icon, color: scheme.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
