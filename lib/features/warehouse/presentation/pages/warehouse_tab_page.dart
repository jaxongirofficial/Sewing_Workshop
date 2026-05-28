import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../l10n/s.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../../shared/widgets/brand/brand_scrollable_sheet.dart';
import '../../../workshop/models/workshop_mock_models.dart';
import '../../../workshop/presentation/providers/workshop_mock_providers.dart';
import 'warehouse_history_page.dart';
import 'warehouse_product_detail_page.dart';
import '../widgets/warehouse_add_item_sheet.dart';
import '../widgets/warehouse_dispatch_sheet.dart';
import '../widgets/warehouse_quick_actions.dart';
import '../widgets/warehouse_category_filter.dart';
import '../widgets/warehouse_empty_state.dart';
import '../widgets/warehouse_labels.dart';
import '../widgets/warehouse_overview_header.dart';
import '../widgets/warehouse_product_tile.dart';

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

  String _performedBy() {
    final user = ref.read(authNotifierProvider).user;
    final name = user?.displayName.trim();
    if (name != null && name.isNotEmpty) return name;
    return '—';
  }

  void _openProductDetail(WarehouseItem item) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => WarehouseProductDetailPage(
          itemId: item.id,
          canEdit: _canEdit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final textTheme = Theme.of(context).textTheme;
    final items = ref.watch(warehouseProvider);

    final filtered = _selectedCategory == null
        ? items
        : items.where((e) => e.category == _selectedCategory).toList();

    final totalItems = items.fold<int>(0, (acc, e) => acc + e.quantity);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        WarehouseOverviewHeader(
          totalPieces: totalItems,
          productCount: items.length,
          onOpenHistory: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(
                builder: (_) => const WarehouseHistoryPage(),
              ),
            );
          },
        ),
        if (_canEdit) ...[
          const SizedBox(height: 14),
          WarehouseQuickActions(
            onAdd: () => _showAddSheet(context),
            onDispatch: () => _showDispatchPickerSheet(context, items),
          ),
        ],
        const SizedBox(height: 16),
        WarehouseCategoryFilter(
          selected: _selectedCategory,
          onSelect: (c) => setState(() => _selectedCategory = c),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              s.warehouseStockList,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Text(
              s.warehouseInStockCount(filtered.length),
              style: textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (filtered.isEmpty)
          WarehouseEmptyState(filtered: _selectedCategory != null)
        else
          for (final item in filtered) ...[
            WarehouseProductTile(
              item: item,
              onTap: () => _openProductDetail(item),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Future<void> _showAddSheet(BuildContext context) async {
    final actor = _performedBy();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => WarehouseAddItemSheet(
        onAdd: (item) {
          ref.read(warehouseProvider.notifier).add(
                item,
                performedBy: item.addedBy ?? actor,
              );
          Navigator.of(sheetCtx).pop();
        },
      ),
    );
  }

  Future<void> _showDispatchSheet(
      BuildContext context, WarehouseItem item) async {
    final actor = _performedBy();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WarehouseDispatchSheet(
        item: item,
        onDispatch: (qty) {
          ref.read(warehouseProvider.notifier).dispatch(
                item.id,
                qty,
                performedBy: actor,
              );
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
