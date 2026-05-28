import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_surface.dart';
import '../../../workshop/models/workshop_mock_models.dart';
import 'warehouse_labels.dart';

class WarehouseProductCard extends StatelessWidget {
  const WarehouseProductCard({
    super.key,
    required this.item,
    required this.canEdit,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    this.onDispatch,
  });

  final WarehouseItem item;
  final bool canEdit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;
  final VoidCallback? onDispatch;

  Color _categoryColor(WarehouseCategory c) => switch (c) {
    WarehouseCategory.clothing => AppColors.brand,
    WarehouseCategory.material => AppColors.success,
    WarehouseCategory.accessory => AppColors.warning,
    WarehouseCategory.other => AppColors.slate,
  };

  IconData _categoryIcon(WarehouseCategory c) => switch (c) {
    WarehouseCategory.clothing => Icons.checkroom_rounded,
    WarehouseCategory.material => Icons.layers_rounded,
    WarehouseCategory.accessory => Icons.diamond_rounded,
    WarehouseCategory.other => Icons.inventory_2_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context);
    final catColor = _categoryColor(item.category);
    final catIcon = _categoryIcon(item.category);
    final isLow = item.quantity <= 5;

    return BrandSurface(
      solid: true,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  catColor.withValues(alpha: isDark ? 0.38 : 0.20),
                  catColor.withValues(alpha: isDark ? 0.20 : 0.08),
                ],
              ),
            ),
            child: Icon(catIcon, color: catColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  warehouseItemName(item, s),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: catColor.withValues(alpha: isDark ? 0.22 : 0.12),
                      ),
                      child: Text(
                        categoryLabel(item.category, s),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: catColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (isLow)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: AppColors.danger.withValues(
                            alpha: isDark ? 0.22 : 0.12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 10,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              s.low,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (item.pricePerUnit != null || item.addedBy != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.pricePerUnit != null) ...[
                        Icon(Icons.sell_outlined,
                            size: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text(
                          '${item.pricePerUnit!.toStringAsFixed(0)} so\'m',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (item.addedBy != null) const SizedBox(width: 8),
                      ],
                      if (item.addedBy != null) ...[
                        Icon(Icons.person_outline_rounded,
                            size: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            item.addedBy!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (canEdit)
            _QuantityControl(
              value: item.quantity,
              unit: unitLabel(item.unit, s),
              onIncrement: onIncrement,
              onDecrement: onDecrement,
              isLow: isLow,
            )
          else
            _QuantityBadge(
              quantity: item.quantity,
              unit: unitLabel(item.unit, s),
              isLow: isLow,
            ),
          if (canEdit) ...[
            const SizedBox(width: 6),
            if (onDispatch != null)
              _DispatchBtn(onTap: onDispatch!),
            const SizedBox(width: 6),
            _DeleteBtn(onTap: onDelete),
          ],
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.value,
    required this.unit,
    required this.onIncrement,
    required this.onDecrement,
    required this.isLow,
  });

  final int value;
  final String unit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isLow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundBtn(
          icon: Icons.remove_rounded,
          onTap: onDecrement,
          active: value > 0,
        ),
        const SizedBox(width: 6),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: isLow ? AppColors.danger : scheme.onSurface,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        _RoundBtn(icon: Icons.add_rounded, onTap: onIncrement, active: true),
      ],
    );
  }
}

class _QuantityBadge extends StatelessWidget {
  const _QuantityBadge({
    required this.quantity,
    required this.unit,
    required this.isLow,
  });

  final int quantity;
  final String unit;
  final bool isLow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isLow ? AppColors.danger : scheme.primary;

    return Container(
      constraints: const BoxConstraints(minWidth: 64),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.35 : 0.22),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$quantity',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: accent,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: accent.withValues(alpha: 0.85),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({
    required this.icon,
    required this.onTap,
    required this.active,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? scheme.primary.withValues(alpha: isDark ? 0.22 : 0.12)
              : (isDark ? AppColors.darkBorder : const Color(0xFFEEF2F8)),
          border: Border.all(
            color: active
                ? scheme.primary.withValues(alpha: isDark ? 0.45 : 0.28)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: active ? scheme.primary : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DispatchBtn extends StatelessWidget {
  const _DispatchBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.warning.withValues(alpha: 0.14),
        ),
        child: const Icon(
          Icons.local_shipping_outlined,
          size: 15,
          color: AppColors.warning,
        ),
      ),
    );
  }
}

class _DeleteBtn extends StatelessWidget {
  const _DeleteBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.danger.withValues(alpha: 0.12),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          size: 16,
          color: AppColors.danger,
        ),
      ),
    );
  }
}
