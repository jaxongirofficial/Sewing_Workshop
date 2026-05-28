import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_scrollable_sheet.dart';
import '../../../workshop/models/workshop_mock_models.dart';
import 'warehouse_labels.dart';

class WarehouseDispatchSheet extends StatefulWidget {
  const WarehouseDispatchSheet({
    super.key,
    required this.item,
    required this.onDispatch,
  });

  final WarehouseItem item;
  final ValueChanged<int> onDispatch;

  @override
  State<WarehouseDispatchSheet> createState() => _WarehouseDispatchSheetState();
}

class _WarehouseDispatchSheetState extends State<WarehouseDispatchSheet> {
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
    final name = warehouseItemName(widget.item, s);

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
            Text(
              s.dispatchProduct,
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '$name · ${s.totalPieces}: ${widget.item.quantity} ${widget.item.unit}',
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
