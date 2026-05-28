import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../l10n/s.dart';
import '../../../workshop/models/workshop_mock_models.dart';
import 'warehouse_labels.dart';

String historyEntryLine(WarehouseHistoryEntry e, S s) {
  final product = warehouseItemName(
    WarehouseItem(
      id: e.productId,
      name: e.productName,
      quantity: 0,
      unit: e.unit,
      category: WarehouseCategory.other,
    ),
    s,
  );
  final unit = unitLabel(e.unit, s);
  final who = e.performedBy;
  final qty = e.quantity.abs();

  return switch (e.type) {
    WarehouseHistoryType.stockIn =>
      s.historyStockInLine(who, qty, unit, product),
    WarehouseHistoryType.stockOut =>
      s.historyStockOutLine(who, qty, unit, product),
    WarehouseHistoryType.adjust => e.quantity >= 0
        ? s.historyAdjustAddLine(who, qty, unit, product)
        : s.historyAdjustRemoveLine(who, qty, unit, product),
  };
}

Color historyTypeColor(WarehouseHistoryType type) => switch (type) {
      WarehouseHistoryType.stockIn => AppColors.success,
      WarehouseHistoryType.stockOut => AppColors.warning,
      WarehouseHistoryType.adjust => AppColors.brand,
    };

IconData historyTypeIcon(WarehouseHistoryType type) => switch (type) {
      WarehouseHistoryType.stockIn => Icons.south_west_rounded,
      WarehouseHistoryType.stockOut => Icons.north_east_rounded,
      WarehouseHistoryType.adjust => Icons.tune_rounded,
    };

String historyTypeLabel(WarehouseHistoryType type, S s) => switch (type) {
      WarehouseHistoryType.stockIn => s.historyStockIn,
      WarehouseHistoryType.stockOut => s.historyStockOut,
      WarehouseHistoryType.adjust => s.historyAdjust,
    };

String formatHistoryTime(DateTime at, S s) {
  final now = DateTime.now();
  final local = at.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final hm =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

  if (day == today) return '$hm · ${s.dateFilterToday}';
  if (day == today.subtract(const Duration(days: 1))) {
    return '$hm · ${s.dateFilterYesterday}';
  }
  return '$hm · ${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
}
