import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../l10n/s.dart';
import '../../../workshop/models/workshop_mock_models.dart';
import 'warehouse_labels.dart';

class WarehouseCategoryFilter extends StatelessWidget {
  const WarehouseCategoryFilter({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final WarehouseCategory? selected;
  final ValueChanged<WarehouseCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final chips = <Widget>[
      _Chip(
        label: s.allCategories,
        selected: selected == null,
        onTap: () => onSelect(null),
      ),
      for (final c in WarehouseCategory.values)
        _Chip(
          label: categoryLabel(c, s),
          selected: selected == c,
          onTap: () => onSelect(c == selected ? null : c),
        ),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: selected
              ? LinearGradient(
                  colors: [
                    scheme.primary,
                    Color.lerp(scheme.primary, Colors.black, 0.18)!,
                  ],
                )
              : null,
          color: selected ? null : (isDark ? AppColors.darkCard : Colors.white),
          border: Border.all(
            color: selected
                ? scheme.primary
                : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
            width: selected ? 0 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? Colors.white : scheme.onSurfaceVariant,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}
