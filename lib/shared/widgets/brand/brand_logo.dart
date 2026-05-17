import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

/// Login va splash uchun yagona brend logo.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 92,
    this.iconSize = 42,
  });

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, AppColors.brandDeep, 0.55) ??
                scheme.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.40),
            blurRadius: 28,
            offset: const Offset(0, 16),
            spreadRadius: -6,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.12),
            blurRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.checkroom_rounded,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}
