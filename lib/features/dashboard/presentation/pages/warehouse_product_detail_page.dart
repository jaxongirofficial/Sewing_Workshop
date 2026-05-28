import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../l10n/s.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../../shared/widgets/brand/brand_dashboard_backdrop.dart';
import '../../../../shared/widgets/brand/brand_surface.dart';
import '../models/workshop_mock_models.dart';
import '../providers/workshop_mock_providers.dart';
import '../widgets/warehouse/warehouse_dispatch_sheet.dart';
import '../widgets/warehouse/warehouse_history_labels.dart';
import '../widgets/warehouse/warehouse_labels.dart';

class WarehouseProductDetailPage extends ConsumerWidget {
  const WarehouseProductDetailPage({
    super.key,
    required this.itemId,
    required this.canEdit,
  });

  final String itemId;
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(warehouseProvider);
    WarehouseItem? item;
    for (final e in items) {
      if (e.id == itemId) {
        item = e;
        break;
      }
    }

    if (item == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    final user = ref.read(authNotifierProvider).user;
    final actorName = user?.displayName.trim();
    final actor = (actorName != null && actorName.isNotEmpty)
        ? actorName
        : '—';

    final history = ref
        .watch(warehouseHistoryProvider)
        .where((e) => e.productId == itemId)
        .toList();

    return _WarehouseProductDetailView(
      itemId: itemId,
      canEdit: canEdit,
      actor: actor,
      history: history,
    );
  }
}

class _WarehouseProductDetailView extends ConsumerWidget {
  const _WarehouseProductDetailView({
    required this.itemId,
    required this.canEdit,
    required this.actor,
    required this.history,
  });

  final String itemId;
  final bool canEdit;
  final String actor;
  final List<WarehouseHistoryEntry> history;

  Color _catColor(WarehouseCategory c) => switch (c) {
        WarehouseCategory.clothing => AppColors.brand,
        WarehouseCategory.material => AppColors.success,
        WarehouseCategory.accessory => AppColors.warning,
        WarehouseCategory.other => AppColors.slate,
      };

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WarehouseItem item,
  ) async {
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
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(warehouseProvider.notifier).remove(item.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _showDispatchSheet(
    BuildContext context,
    WidgetRef ref,
    WarehouseItem item,
  ) async {
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
                  s.dispatchSuccess(qty, warehouseItemName(item, s)),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _adjust(WidgetRef ref, WarehouseItem item, int delta) {
    HapticFeedback.selectionClick();
    ref.read(warehouseProvider.notifier).updateQuantity(
          item.id,
          delta,
          performedBy: actor,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final items = ref.watch(warehouseProvider);
    WarehouseItem? item;
    for (final e in items) {
      if (e.id == itemId) {
        item = e;
        break;
      }
    }
    if (item == null) return const SizedBox.shrink();
    final product = item;

    final catColor = _catColor(product.category);
    final isLow = product.quantity <= 5;
    final name = warehouseItemName(product, s);
    final unit = unitLabel(product.unit, s);
    final addedBy = product.addedBy?.trim().isNotEmpty == true
        ? product.addedBy!
        : s.notSpecified;
    final qtyColor = isLow ? AppColors.danger : catColor;

    return Stack(
      fit: StackFit.expand,
      children: [
        const BrandDashboardBackdrop(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: scheme.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              name,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              BrandSurface(
                solid: true,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      s.productInStock,
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${product.quantity}',
                      style: textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: qtyColor,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      unit,
                      style: textTheme.titleSmall?.copyWith(
                        color: qtyColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isLow) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s.low,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionTitle(text: s.productSectionDetails),
              const SizedBox(height: 8),
              BrandSurface(
                solid: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.category_outlined,
                      label: s.category,
                      value: categoryLabel(product.category, s),
                    ),
                    Divider(
                      height: 1,
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: s.addedBy,
                      value: addedBy,
                    ),
                    if (product.pricePerUnit != null) ...[
                      Divider(
                        height: 1,
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                      _InfoRow(
                        icon: Icons.sell_outlined,
                        label: s.pricePerUnit,
                        value: '${product.pricePerUnit!.toStringAsFixed(0)} so\'m',
                      ),
                    ],
                  ],
                ),
              ),
              if (canEdit) ...[
                const SizedBox(height: 18),
                _SectionTitle(text: s.productSectionActions),
                const SizedBox(height: 8),
                BrandSurface(
                  solid: true,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _QtyStepper(
                        quantity: product.quantity,
                        unit: unit,
                        onDecrement: product.quantity > 0
                            ? () => _adjust(ref, product, -1)
                            : null,
                        onIncrement: () => _adjust(ref, product, 1),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: product.quantity > 0
                            ? () => _showDispatchSheet(context, ref, product)
                            : null,
                        icon: const Icon(Icons.local_shipping_outlined),
                        label: Text(s.dispatchConfirm),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => _confirmDelete(context, ref, product),
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: Text(s.delete),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (history.isNotEmpty) ...[
                const SizedBox(height: 18),
                _SectionTitle(text: s.productSectionHistory),
                const SizedBox(height: 8),
                ...history.take(10).map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: BrandSurface(
                          solid: true,
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: historyTypeColor(e.type)
                                      .withValues(alpha: 0.14),
                                ),
                                child: Icon(
                                  historyTypeIcon(e.type),
                                  size: 18,
                                  color: historyTypeColor(e.type),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      historyEntryLine(e, s),
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatHistoryTime(e.at, s),
                                      style: textTheme.labelSmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.quantity,
    required this.unit,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final String unit;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? AppColors.darkCardHigh : const Color(0xFFF4F7FC),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE6EBF4),
        ),
      ),
      child: Row(
        children: [
          _StepBtn(icon: Icons.remove_rounded, onTap: onDecrement),
          Expanded(
            child: Text(
              '$quantity $unit',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
          ),
          _StepBtn(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: enabled ? scheme.primary : scheme.outline,
      ),
    );
  }
}
