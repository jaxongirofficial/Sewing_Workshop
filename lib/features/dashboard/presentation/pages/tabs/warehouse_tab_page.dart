import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_radius.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../l10n/s.dart';
import '../../../../../shared/widgets/brand/brand_scrollable_sheet.dart';
import '../../models/workshop_mock_models.dart';
import '../../providers/workshop_mock_providers.dart';
import '../../widgets/warehouse/warehouse_add_button.dart';
import '../../widgets/warehouse/warehouse_add_item_sheet.dart';
import '../../widgets/warehouse/warehouse_category_filter.dart';
import '../../widgets/warehouse/warehouse_empty_state.dart';
import '../../widgets/warehouse/warehouse_labels.dart';
import '../../widgets/warehouse/warehouse_product_card.dart';
import '../../widgets/warehouse/warehouse_summary_row.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        WarehouseSummaryRow(
          totalItems: totalItems,
          productTypes: items.length,
          categories: categoryCount,
        ),
        const SizedBox(height: 16),
        WarehouseCategoryFilter(
          selected: _selectedCategory,
          onSelect: (c) => setState(() => _selectedCategory = c),
        ),
        if (_canEdit) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: WarehouseAddButton(
                    onTap: () => _showAddSheet(context)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DispatchAllButton(
                    onTap: () => _showDispatchPickerSheet(context, items)),
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          WarehouseEmptyState(filtered: _selectedCategory != null)
        else
          for (final item in filtered) ...[
            WarehouseProductCard(
              item: item,
              canEdit: _canEdit,
              onIncrement: () => ref
                  .read(warehouseProvider.notifier)
                  .updateQuantity(item.id, 1),
              onDecrement: () => ref
                  .read(warehouseProvider.notifier)
                  .updateQuantity(item.id, -1),
              onDelete: () => _confirmDelete(context, item),
              onDispatch: _canEdit
                  ? () => _showDispatchSheet(context, item)
                  : null,
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
          s.deleteWarehouseItemMessage(warehouseItemName(item, s)),
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
      builder: (sheetCtx) => WarehouseAddItemSheet(
        onAdd: (item) {
          ref.read(warehouseProvider.notifier).add(item);
          Navigator.of(sheetCtx).pop();
        },
      ),
    );
  }

  Future<void> _showDispatchSheet(
      BuildContext context, WarehouseItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DispatchSheet(
        item: item,
        onDispatch: (qty) {
          ref.read(warehouseProvider.notifier).dispatch(item.id, qty);
          if (context.mounted) {
            final s = S.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    s.dispatchSuccess(qty, warehouseItemName(item, s))),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _showDispatchPickerSheet(
      BuildContext context, List<WarehouseItem> items) async {
    if (items.isEmpty) return;
    final selected = await showModalBottomSheet<WarehouseItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemPickerSheet(items: items),
    );
    if (selected != null && context.mounted) {
      await _showDispatchSheet(context, selected);
    }
  }
}

// ─── Dispatch All button ──────────────────────────────────────────────────────

class _DispatchAllButton extends StatelessWidget {
  const _DispatchAllButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            color: AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.12),
            border: Border.all(
              color:
                  AppColors.warning.withValues(alpha: isDark ? 0.5 : 0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_shipping_outlined,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  s.dispatchProduct,
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Item Picker Sheet ────────────────────────────────────────────────────────

class _ItemPickerSheet extends StatelessWidget {
  const _ItemPickerSheet({required this.items});
  final List<WarehouseItem> items;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BrandScrollableSheet(
      child: BrandSheetContainer(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandSheetHandle(),
            const SizedBox(height: 14),
            Text(
              s.dispatchProduct,
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                title: Text(warehouseItemName(item, s),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                    '${item.quantity} ${unitLabel(item.unit, s)}',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(context, item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dispatch Sheet ───────────────────────────────────────────────────────────

class _DispatchSheet extends StatefulWidget {
  const _DispatchSheet({required this.item, required this.onDispatch});
  final WarehouseItem item;
  final ValueChanged<int> onDispatch;

  @override
  State<_DispatchSheet> createState() => _DispatchSheetState();
}

class _DispatchSheetState extends State<_DispatchSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final n = int.tryParse(_ctrl.text.trim());
    if (n == null || n <= 0 || n > widget.item.quantity) return;
    widget.onDispatch(n);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BrandScrollableSheet(
      child: BrandSheetContainer(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          14 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BrandSheetHandle(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.dispatchProduct,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
              const SizedBox(height: 4),
            Text(
              '${widget.item.name}  •  ${s.totalPieces}: ${widget.item.quantity} ${widget.item.unit}',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: s.dispatchQtyHint,
                suffixText: widget.item.unit,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                helperText: '${s.totalPieces}: ${widget.item.quantity}',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: Text(s.dispatchConfirm),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
