import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_dashboard_backdrop.dart';
import '../../../../shared/widgets/brand/brand_surface.dart';
import '../../../workshop/models/workshop_mock_models.dart';
import '../../../workshop/presentation/providers/workshop_mock_providers.dart';
import '../widgets/warehouse_history_labels.dart';

class WarehouseHistoryPage extends ConsumerStatefulWidget {
  const WarehouseHistoryPage({super.key});

  @override
  ConsumerState<WarehouseHistoryPage> createState() =>
      _WarehouseHistoryPageState();
}

class _WarehouseHistoryPageState extends ConsumerState<WarehouseHistoryPage> {
  WarehouseHistoryType? _filter;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final all = ref.watch(warehouseHistoryProvider);
    final entries = _filter == null
        ? all
        : all.where((e) => e.type == _filter).toList();

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
              s.warehouseHistory,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              s.warehouseHistoryHint,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: s.historyAll,
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: s.historyStockIn,
                  selected: _filter == WarehouseHistoryType.stockIn,
                  color: AppColors.success,
                  onTap: () => setState(
                    () => _filter = WarehouseHistoryType.stockIn,
                  ),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: s.historyStockOut,
                  selected: _filter == WarehouseHistoryType.stockOut,
                  color: AppColors.warning,
                  onTap: () => setState(
                    () => _filter = WarehouseHistoryType.stockOut,
                  ),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: s.historyAdjust,
                  selected: _filter == WarehouseHistoryType.adjust,
                  color: AppColors.brand,
                  onTap: () => setState(
                    () => _filter = WarehouseHistoryType.adjust,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: entries.isEmpty
                ? _HistoryEmpty(s: s)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: entries.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) => _HistoryTile(entry: entries[i]),
                  ),
          ),
        ],
      ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected
              ? accent.withValues(alpha: isDark ? 0.28 : 0.14)
              : (isDark ? AppColors.darkCard : Colors.white),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.5)
                : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? accent : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final WarehouseHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = historyTypeColor(entry.type);
    final icon = historyTypeIcon(entry.type);

    return BrandSurface(
      solid: true,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  historyEntryLine(entry, s),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatHistoryTime(entry.at, s),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              color: color.withValues(alpha: 0.12),
            ),
            child: Text(
              historyTypeLabel(entry.type, s),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty({required this.s});

  final S s;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 48,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              s.historyEmptyTitle,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              s.historyEmptyHint,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
