import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_radius.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../l10n/s.dart';
import '../../models/workshop_mock_models.dart';
import '../../providers/workshop_mock_providers.dart';
import '../../../../../shared/widgets/brand/brand_surface.dart';
import '../../../../../shared/widgets/brand/brand_text_field.dart';

String _categoryLabel(WarehouseCategory category, S s) => switch (category) {
  WarehouseCategory.clothing => s.categoryClothing,
  WarehouseCategory.material => s.categoryMaterial,
  WarehouseCategory.accessory => s.categoryAccessory,
  WarehouseCategory.other => s.categoryOther,
};

String _warehouseItemName(WarehouseItem item, S s) => switch (item.id) {
  'w-1' => s.productPants,
  'w-2' => s.productDress,
  'w-3' => s.productSleeve,
  'w-4' => s.productSkirt,
  'w-5' => s.productJacket,
  'w-6' => s.productBag,
  'w-7' => s.productBelt,
  'w-8' => s.productBlueFabric,
  'w-9' => s.productWhiteThread,
  'w-10' => s.productButton,
  _ => item.name,
};

String _unitLabel(String unit, S s) => switch (unit) {
  'ta' => s.unitPiece,
  'metr' => s.unitMeter,
  'dona' => s.unitItem,
  _ => unit,
};

class WarehouseTabPage extends ConsumerStatefulWidget {
  const WarehouseTabPage({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<WarehouseTabPage> createState() => _WarehouseTabPageState();
}

class _WarehouseTabPageState extends ConsumerState<WarehouseTabPage> {
  WarehouseCategory? _selectedCategory;

  bool get _canEdit =>
      widget.role == UserRole.owner || widget.role == UserRole.manager;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(warehouseProvider);

    final filtered = _selectedCategory == null
        ? items
        : items.where((e) => e.category == _selectedCategory).toList();

    final totalItems = items.fold<int>(0, (acc, e) => acc + e.quantity);
    final categoryCount = WarehouseCategory.values
        .where((c) => items.any((e) => e.category == c))
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        _SummaryRow(
          totalItems: totalItems,
          productTypes: items.length,
          categories: categoryCount,
        ),
        const SizedBox(height: 16),
        _CategoryFilter(
          selected: _selectedCategory,
          onSelect: (c) => setState(() => _selectedCategory = c),
        ),
        const SizedBox(height: 16),
        if (_canEdit) ...[
          _AddButton(onTap: () => _showAddSheet(context)),
          const SizedBox(height: 16),
        ],
        if (filtered.isEmpty)
          _EmptyState(filtered: _selectedCategory != null)
        else
          for (final item in filtered) ...[
            _ProductCard(
              item: item,
              canEdit: _canEdit,
              onIncrement: () => ref
                  .read(warehouseProvider.notifier)
                  .updateQuantity(item.id, 1),
              onDecrement: () => ref
                  .read(warehouseProvider.notifier)
                  .updateQuantity(item.id, -1),
              onDelete: () => _confirmDelete(context, item),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WarehouseItem item) async {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(s.deleteConfirmTitle),
        content: Text(
          s.deleteWarehouseItemMessage(_warehouseItemName(item, s)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              s.cancel,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(warehouseProvider.notifier).remove(item.id);
    }
  }

  Future<void> _showAddSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _AddItemSheet(
        onAdd: (item) {
          ref.read(warehouseProvider.notifier).add(item);
          Navigator.of(sheetCtx).pop();
        },
      ),
    );
  }
}

// ─── Summary row ──────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
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
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: scheme.onSurface,
            ),
          ),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category filter ──────────────────────────────────────────────────────────

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selected, required this.onSelect});

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
          label: _categoryLabel(c, s),
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
    final s = S.of(context);

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

// ─── Add button ───────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context); // <-- SHU QATORNI QO‘SHING

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              colors: [
                scheme.primary,
                Color.lerp(scheme.primary, Colors.black, isDark ? 0.12 : 0.22)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.40),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: -6,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                s.addProduct,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Product card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.canEdit,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  final WarehouseItem item;
  final bool canEdit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

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
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Kategoriya badge
          Container(
            width: 48,
            height: 48,
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
          const SizedBox(width: 14),

          // Nom + kategoriya
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _warehouseItemName(item, s),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
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
                        _categoryLabel(item.category, s),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: catColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (isLow) ...[
                      const SizedBox(width: 6),
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
                        child: Text(
                          s.low,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.danger,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Miqdor
          if (canEdit)
            _QuantityControl(
              value: item.quantity,
              unit: _unitLabel(item.unit, s),
              onIncrement: onIncrement,
              onDecrement: onDecrement,
              isLow: isLow,
            )
          else
            _QuantityBadge(
              quantity: item.quantity,
              unit: _unitLabel(item.unit, s),
              isLow: isLow,
            ),

          if (canEdit) ...[
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$quantity',
          style: TextStyle(
            fontSize: 20,
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

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtered});
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            filtered
                ? Icons.filter_list_off_rounded
                : Icons.inventory_2_outlined,
            size: 64,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            filtered ? s.filteredEmptyTitle : s.warehouseEmptyTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            filtered ? s.filteredEmptyHint : s.warehouseEmptyHint,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add item bottom sheet ────────────────────────────────────────────────────

class _AddItemSheet extends ConsumerStatefulWidget {
  const _AddItemSheet({required this.onAdd});
  final ValueChanged<WarehouseItem> onAdd;

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<_AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _unitCtrl = TextEditingController();
  WarehouseCategory _cat = WarehouseCategory.clothing;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;
    final item = WarehouseItem(
      id: 'w-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      quantity: qty,
      unit: _unitCtrl.text.trim().isEmpty ? 'ta' : _unitCtrl.text.trim(),
      category: _cat,
    );
    widget.onAdd(item);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final s = S.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, viewInsets.bottom + 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE6EBF4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.50 : 0.10),
              blurRadius: 30,
              offset: const Offset(0, 14),
              spreadRadius: -10,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  s.newProduct,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 16),

                BrandTextField(
                  controller: _nameCtrl,
                  hintText: s.productNameHint,
                  prefixIcon: Icons.inventory_2_outlined,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? s.nameRequired : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: BrandTextField(
                        controller: _qtyCtrl,
                        hintText: s.quantityHint,
                        prefixIcon: Icons.numbers_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 0) return s.numberRequired;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BrandTextField(
                        controller: _unitCtrl,
                        hintText: s.unitHint,
                        prefixIcon: Icons.straighten_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  s.category,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in WarehouseCategory.values)
                      _SheetChip(
                        label: _categoryLabel(c, s),
                        selected: _cat == c,
                        onTap: () => setState(() => _cat = c),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _submit,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        gradient: LinearGradient(
                          colors: [
                            scheme.primary,
                            Color.lerp(
                              scheme.primary,
                              Colors.black,
                              isDark ? 0.10 : 0.22,
                            )!,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.40),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                            spreadRadius: -6,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        s.save,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetChip extends StatelessWidget {
  const _SheetChip({
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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected
              ? scheme.primary.withValues(alpha: isDark ? 0.25 : 0.14)
              : (isDark ? AppColors.darkCardHigh : const Color(0xFFF4F7FC)),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: isDark ? 0.55 : 0.40)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
