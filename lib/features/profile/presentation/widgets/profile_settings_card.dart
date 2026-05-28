import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';

class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({super.key, required this.rows});

  final List<ProfileSettingRow> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
            color: AppColors.shadow.withValues(alpha: isDark ? 0.28 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: -10,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 66),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: scheme.outlineVariant
                      .withValues(alpha: isDark ? 0.40 : 0.60),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class ProfileSettingRow extends StatelessWidget {
  const ProfileSettingRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: scheme.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(icon, color: scheme.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
