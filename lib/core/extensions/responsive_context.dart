import 'package:flutter/material.dart';

import '../../config/theme/app_spacing.dart';

/// Layout breakpoints for responsive admin-style layouts.
abstract final class Breakpoints {
  static const double compact = 600;
  static const double medium = 900;
  static const double expanded = 1280;
}

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  bool get isCompactWidth => screenSize.width < Breakpoints.compact;

  bool get isMediumWidth =>
      screenSize.width >= Breakpoints.compact &&
      screenSize.width < Breakpoints.medium;

  double get pageHorizontalPadding {
    final w = screenSize.width;
    if (w >= Breakpoints.expanded) return AppSpacing.xxl;
    if (w >= Breakpoints.medium) return AppSpacing.xl;
    return AppSpacing.pageHorizontal;
  }
}
