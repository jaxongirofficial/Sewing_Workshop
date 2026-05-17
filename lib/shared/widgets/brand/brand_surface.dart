import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_radius.dart';

/// Universal panel — solid yoki glass variantida.
///
/// — `solid` (default): qattiq oq/qora fon + chegara + soya — dashboard uchun.
/// — `solid: false`: blur + yarim shaffof gradient — login/splash uchun.
class BrandSurface extends StatelessWidget {
  const BrandSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.radius = AppRadius.lg,
    this.tinted = false,
    this.solid = true,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  /// Brend rangiga ozgina bo‘yalgan variant.
  final bool tinted;

  /// `true` — qattiq fon (dashboard), `false` — blur glass (login).
  final bool solid;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (solid) return _solid(context);
    return _glass(context);
  }

  Widget _solid(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? scheme.surface : Colors.white;

    final tintColor = tinted
        ? Color.lerp(baseColor, scheme.primary, isDark ? 0.08 : 0.04)!
        : baseColor;

    final card = Container(
      decoration: BoxDecoration(
        color: tintColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark
              ? scheme.outline.withValues(alpha: 0.35)
              : const Color(0xFFE6EBF4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: isDark ? 0.34 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: scheme.primary.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    return margin == null ? card : Padding(padding: margin!, child: card);
  }

  Widget _glass(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? scheme.surface : Colors.white;
    final topAlpha = isDark ? 0.50 : 0.86;
    final bottomAlpha = isDark ? 0.36 : 0.66;

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor.withValues(alpha: topAlpha),
                baseColor.withValues(alpha: bottomAlpha),
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isDark
                  ? scheme.outline.withValues(alpha: 0.32)
                  : Colors.white.withValues(alpha: 0.95),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow
                    .withValues(alpha: isDark ? 0.45 : 0.07),
                blurRadius: isDark ? 30 : 36,
                offset: const Offset(0, 18),
                spreadRadius: -10,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(radius),
              splashColor: scheme.primary.withValues(alpha: 0.08),
              highlightColor: Colors.transparent,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );

    return margin == null ? card : Padding(padding: margin!, child: card);
  }
}
