import 'package:flutter/material.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_radius.dart';
import '../../../../../l10n/s.dart';
import '../../../../../shared/widgets/brand/brand_surface.dart';

/// Kirim va chiqarish — vertikal, aniq ajratilgan amallar.
class WarehouseQuickActions extends StatelessWidget {
  const WarehouseQuickActions({
    super.key,
    required this.onAdd,
    required this.onDispatch,
  });

  final VoidCallback onAdd;
  final VoidCallback onDispatch;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BrandSurface(
      solid: true,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.add_box_rounded,
            label: s.addProduct,
            accent: Theme.of(context).colorScheme.primary,
            filled: true,
            onTap: onAdd,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 1,
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.35),
            ),
          ),
          _ActionTile(
            icon: Icons.local_shipping_rounded,
            label: s.dispatchConfirm,
            accent: AppColors.warning,
            filled: false,
            onTap: onDispatch,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.accent,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = filled
        ? LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              accent,
              Color.lerp(accent, Colors.black, isDark ? 0.15 : 0.28)!,
            ],
          )
        : null;

    final tileColor = filled
        ? null
        : accent.withValues(alpha: isDark ? 0.14 : 0.09);

    final fg = filled ? Colors.white : accent;
    final subFg = filled
        ? Colors.white.withValues(alpha: 0.85)
        : scheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: bg,
            color: tileColor,
            border: filled
                ? null
                : Border.all(color: accent.withValues(alpha: 0.28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled
                      ? Colors.white.withValues(alpha: 0.2)
                      : accent.withValues(alpha: isDark ? 0.22 : 0.14),
                ),
                child: Icon(icon, color: fg, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: filled ? Colors.white : scheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: subFg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
