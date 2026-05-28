import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_surface.dart';

class WarehouseSummaryRow extends StatelessWidget {
  const WarehouseSummaryRow({
    super.key,
    required this.totalItems,
    required this.productTypes,
    required this.categories,
  });

  final int totalItems;
  final int productTypes;
  final int categories;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Row(
      children: [
        Expanded(
          child: _SumCard(
            icon: Icons.inventory_2_rounded,
            value: '$totalItems',
            label: s.totalPieces,
            color: AppColors.brand,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SumCard(
            icon: Icons.category_rounded,
            value: '$productTypes',
            label: s.productTypes,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SumCard(
            icon: Icons.layers_rounded,
            value: '$categories',
            label: s.category,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _SumCard extends StatelessWidget {
  const _SumCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BrandSurface(
      solid: true,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: isDark ? 0.35 : 0.18),
                  color.withValues(alpha: isDark ? 0.18 : 0.08),
                ],
              ),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: scheme.onSurface,
                fontSize: 20,
                height: 1.0,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.2,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
