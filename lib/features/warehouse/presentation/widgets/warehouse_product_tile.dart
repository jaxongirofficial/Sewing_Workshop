import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_surface.dart';
import '../../../workshop/models/workshop_mock_models.dart';
import 'warehouse_labels.dart';

/// Ro'yxat qatori — nom, kim kiritdi, soni. Bosilsa info sahifaga.
class WarehouseProductTile extends StatelessWidget {
  const WarehouseProductTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final WarehouseItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLow = item.quantity <= 5;
    final name = warehouseItemName(item, s);
    final unit = unitLabel(item.unit, s);
    final addedBy = item.addedBy?.trim().isNotEmpty == true
        ? item.addedBy!
        : s.notSpecified;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: BrandSurface(
          solid: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.addedBy}: $addedBy',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.quantity} $unit',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isLow ? AppColors.danger : scheme.onSurface,
                      height: 1,
                    ),
                  ),
                  if (isLow) ...[
                    const SizedBox(height: 4),
                    Text(
                      s.low,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
