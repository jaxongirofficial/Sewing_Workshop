import 'package:flutter/material.dart';

import '../../../../config/theme/app_radius.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_surface.dart';

/// Bosh sahifada xodimlar bo'limi kartasi (owner/manager uchun).
class HomeWorkersCard extends StatelessWidget {
  const HomeWorkersCard({
    super.key,
    required this.workerCount,
    required this.onTap,
    this.showAddButton = false,
    this.onAdd,
  });

  final int workerCount;
  final VoidCallback onTap;
  final bool showAddButton;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context);

    final iconBox = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: isDark ? 0.32 : 0.18),
            scheme.primary.withValues(alpha: isDark ? 0.16 : 0.06),
          ],
        ),
        border: Border.all(
            color: scheme.primary.withValues(alpha: isDark ? 0.4 : 0.2)),
      ),
      child:
          Icon(Icons.groups_2_rounded, color: scheme.primary, size: 24),
    );

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.workersSection,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          s.workersCount(workerCount),
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showAddButton && onAdd != null) ...[
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: s.addEmployeeAction,
            style: IconButton.styleFrom(
              backgroundColor: scheme.primary.withValues(alpha: 0.1),
              foregroundColor: scheme.primary,
              padding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(width: 6),
        ],
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(s.all),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, size: 16),
            ],
          ),
        ),
      ],
    );

    return SizedBox(
      width: double.infinity,
      child: BrandSurface(
        radius: AppRadius.lg,
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 300) {
              return Row(
                children: [
                  iconBox,
                  const SizedBox(width: 14),
                  Expanded(child: titleBlock),
                  actions,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    iconBox,
                    const SizedBox(width: 14),
                    Expanded(child: titleBlock),
                  ],
                ),
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          },
        ),
      ),
    );
  }
}
