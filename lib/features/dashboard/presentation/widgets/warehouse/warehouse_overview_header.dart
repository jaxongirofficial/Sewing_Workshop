import 'package:flutter/material.dart';

import '../../../../../l10n/s.dart';
import '../../../../../shared/widgets/brand/brand_surface.dart';

class WarehouseOverviewHeader extends StatelessWidget {
  const WarehouseOverviewHeader({
    super.key,
    required this.totalPieces,
    required this.productCount,
    required this.onOpenHistory,
  });

  final int totalPieces;
  final int productCount;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BrandSurface(
      solid: true,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withValues(alpha: isDark ? 0.35 : 0.2),
                  scheme.primary.withValues(alpha: isDark ? 0.15 : 0.06),
                ],
              ),
            ),
            child: Icon(
              Icons.warehouse_rounded,
              color: scheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalPieces',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    height: 1,
                  ),
                ),
                Text(
                  s.totalPieces,
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.warehouseInStockCount(productCount),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onOpenHistory,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: scheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.22),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_rounded, color: scheme.primary, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      s.warehouseHistory,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
