import 'package:flutter/material.dart';

import '../../../config/theme/app_spacing.dart';
import '../../../core/extensions/responsive_context.dart';

class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = AppSpacing.authMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class ResponsiveScrollablePage extends StatelessWidget {
  const ResponsiveScrollablePage({
    super.key,
    required this.child,
    this.maxWidth = AppSpacing.dashboardMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final horizontal = context.pageHorizontalPadding;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            AppSpacing.xl,
            horizontal,
            AppSpacing.xxxxl,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight - AppSpacing.xxxxl - AppSpacing.xl,
                maxWidth: maxWidth,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
