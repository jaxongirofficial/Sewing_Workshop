import 'package:flutter/material.dart';

import '../../../config/theme/app_radius.dart';
import '../../../config/theme/app_shadows.dart';
import '../../../config/theme/app_spacing.dart';

class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.radius = AppRadius.md,
    this.clipBehavior = Clip.antiAlias,
    this.hoverable = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double radius;
  final Clip clipBehavior;
  final bool hoverable;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(
        0,
        _hovered && widget.hoverable ? -2 : 0,
        0,
      ),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? scheme.surface,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: widget.borderColor ??
              scheme.outlineVariant.withValues(alpha: 0.72),
        ),
        boxShadow: _hovered && widget.hoverable
            ? AppShadows.surfaceHover(scheme.shadow)
            : AppShadows.surface(scheme.shadow),
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: widget.clipBehavior,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.radius),
          splashColor: scheme.primary.withValues(alpha: 0.05),
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onHover: widget.hoverable
              ? (value) => setState(() => _hovered = value)
              : null,
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: widget.child,
          ),
        ),
      ),
    );

    return MouseRegion(
      onEnter: widget.hoverable ? (_) => setState(() => _hovered = true) : null,
      onExit: widget.hoverable ? (_) => setState(() => _hovered = false) : null,
      child: widget.margin == null
          ? card
          : Padding(
              padding: widget.margin!,
              child: card,
            ),
    );
  }
}
