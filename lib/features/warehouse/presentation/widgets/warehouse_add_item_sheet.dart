import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_scrollable_sheet.dart';
import '../../../../shared/widgets/brand/brand_text_field.dart';
import '../../../workshop/models/workshop_mock_models.dart';
import 'warehouse_labels.dart';

class WarehouseAddItemSheet extends ConsumerStatefulWidget {
  const WarehouseAddItemSheet({super.key, required this.onAdd});

  final ValueChanged<WarehouseItem> onAdd;

  @override
  ConsumerState<WarehouseAddItemSheet> createState() =>
      _WarehouseAddItemSheetState();
}

class _WarehouseAddItemSheetState extends ConsumerState<WarehouseAddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _unitCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _addedByCtrl = TextEditingController();
  WarehouseCategory _cat = WarehouseCategory.clothing;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _unitCtrl.dispose();
    _priceCtrl.dispose();
    _addedByCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;
    final price = double.tryParse(_priceCtrl.text.trim());
    final addedBy = _addedByCtrl.text.trim();
    final item = WarehouseItem(
      id: 'w-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      quantity: qty,
      unit: _unitCtrl.text.trim().isEmpty ? 'ta' : _unitCtrl.text.trim(),
      category: _cat,
      pricePerUnit: price,
      addedBy: addedBy.isEmpty ? null : addedBy,
    );
    widget.onAdd(item);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context);

    return BrandScrollableSheet(
      child: BrandSheetContainer(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BrandSheetHandle(),
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
                Row(
                  children: [
                    Expanded(
                      child: BrandTextField(
                        controller: _priceCtrl,
                        hintText: s.priceHint,
                        prefixIcon: Icons.sell_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BrandTextField(
                        controller: _addedByCtrl,
                        hintText: s.addedByHint,
                        prefixIcon: Icons.person_outline_rounded,
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
                        label: categoryLabel(c, s),
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
                        style: const TextStyle(
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
