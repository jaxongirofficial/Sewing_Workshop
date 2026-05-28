import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_radius.dart';

/// Modal bottom sheet: scroll + aniq maxHeight (LayoutBuilder infinity muammosini oldini oladi).
class BrandScrollableSheet extends StatelessWidget {
  const BrandScrollableSheet({
    super.key,
    required this.child,
    this.maxHeightFactor = 0.92,
  });

  final Widget child;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final screenH = MediaQuery.sizeOf(context).height;
    final maxHeight = screenH * maxHeightFactor - viewPadding.top;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16 + viewInsets.bottom + viewPadding.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: child,
        ),
      ),
    );
  }
}

/// Sheet ichidagi konteyner (dizayn o'zgarmaydi).
class BrandSheetContainer extends StatelessWidget {
  const BrandSheetContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(18, 18, 18, 14),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE6EBF4),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.55)
                : AppColors.shadow.withValues(alpha: 0.10),
            blurRadius: 30,
            offset: const Offset(0, 14),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class BrandSheetHandle extends StatelessWidget {
  const BrandSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
