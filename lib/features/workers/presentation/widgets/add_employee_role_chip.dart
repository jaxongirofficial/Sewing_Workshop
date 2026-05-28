import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';

class AddEmployeeRoleChip extends StatelessWidget {
  const AddEmployeeRoleChip({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: isDark ? 0.25 : 0.14),
                    scheme.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                  ],
                )
              : null,
          color: selected
              ? null
              : (isDark
                  ? AppColors.darkCardHigh
                  : const Color(0xFFF4F7FC)),
          border: Border.all(
            color: selected
                ? scheme.primary
                : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: -6,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: selected
                    ? LinearGradient(
                        colors: [
                          scheme.primary,
                          Color.lerp(scheme.primary, Colors.black, 0.18)!,
                        ],
                      )
                    : null,
                color: selected
                    ? null
                    : scheme.primary.withValues(alpha: 0.12),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : scheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: selected ? scheme.primary : scheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
