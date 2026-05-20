import 'package:flutter/material.dart';

import '../../../../../config/theme/app_radius.dart';

class AddEmployeeBirthDateField extends StatelessWidget {
  const AddEmployeeBirthDateField({
    super.key,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final DateTime? value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasValue = value != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            color: isDark ? scheme.surfaceContainerHigh : Colors.white,
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.cake_rounded,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: hasValue
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant.withValues(alpha: 0.65),
                    fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_month_rounded,
                color: scheme.primary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
