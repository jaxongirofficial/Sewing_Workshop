import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_radius.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../l10n/s.dart';
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
        const SizedBox(height: 16),
        if (_canEdit) ...[
          WarehouseAddButton(onTap: () => _showAddSheet(context)),
          const SizedBox(height: 16),
        ],
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
}
