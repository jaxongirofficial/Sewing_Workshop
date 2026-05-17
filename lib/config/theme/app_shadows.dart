import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static List<BoxShadow> surface([Color color = AppColors.shadow]) => [
        BoxShadow(
          color: color.withValues(alpha: 0.05),
          blurRadius: 26,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: color.withValues(alpha: 0.025),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> surfaceHover([Color color = AppColors.shadow]) => [
        BoxShadow(
          color: color.withValues(alpha: 0.07),
          blurRadius: 32,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: color.withValues(alpha: 0.03),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
