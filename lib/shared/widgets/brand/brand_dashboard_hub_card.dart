import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_radius.dart';

/// Bosh sahifa uchun kvadrat stat kartochka.
class BrandDashboardHubCard extends StatelessWidget {
  const BrandDashboardHubCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    required this.actionLabel,
    required this.onTap,
    this.chipLabel,
    this.chipIcon,
    this.accentColor,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final String actionLabel;
  final VoidCallback onTap;
  final String? chipLabel;
  final IconData? chipIcon;
  final Color? accentColor;

  /// `true` — butun enni egallaydigan gorizontal banner.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? scheme.primary;

    final baseColor = isDark ? scheme.surface : Colors.white;
    final borderColor = isDark
        ? scheme.outline.withValues(alpha: 0.35)
        : const Color(0xFFE6EBF4);

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      color: baseColor,
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: isDark ? 0.32 : 0.06),
          blurRadius: 20,
          offset: const Offset(0, 10),
          spreadRadius: -10,
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: accent.withValues(alpha: 0.10),
        highlightColor: accent.withValues(alpha: 0.05),
        child: Ink(
          decoration: decoration,
          child: Padding(
            padding: EdgeInsets.all(fullWidth ? 16 : 14),
            child: fullWidth ? _buildWide(context) : _buildSquare(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSquare(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? scheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HubIconBadge(icon: icon, color: accent),
            const Spacer(),
            if (chipLabel != null)
              Flexible(
                child: _HubChip(
                  label: chipLabel!,
                  icon: chipIcon ?? Icons.circle,
                  color: accent,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: scheme.onSurface,
            height: 1.0,
            fontSize: 26,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          caption,
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            height: 1.2,
            fontSize: 11,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        _ActionStrip(
          label: actionLabel,
          accent: accent,
          isDark: isDark,
          compact: true,
        ),
      ],
    );
  }

  Widget _buildWide(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? scheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _HubIconBadge(icon: icon, color: accent, size: 50),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label.toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant
                                .withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                            fontSize: 10.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chipLabel != null) ...[
                        const SizedBox(width: 8),
                        _HubChip(
                          label: chipLabel!,
                          icon: chipIcon ?? Icons.circle,
                          color: accent,
                          large: true,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: scheme.onSurface,
                      height: 1.0,
                      fontSize: 28,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ActionStrip(
          label: actionLabel,
          accent: accent,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _ActionStrip extends StatelessWidget {
  const _ActionStrip({
    required this.label,
    required this.accent,
    required this.isDark,
    this.compact = false,
  });

  final String label;
  final Color accent;
  final bool isDark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.16 : 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 8 : 10,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 10.5 : 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded, size: 16, color: accent),
          ],
        ),
      ),
    );
  }
}

class _HubIconBadge extends StatelessWidget {
  const _HubIconBadge({
    required this.icon,
    required this.color,
    this.size = 40,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            Color.lerp(color, Colors.black, 0.18)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.52),
    );
  }
}

class _HubChip extends StatelessWidget {
  const _HubChip({
    required this.label,
    required this.icon,
    required this.color,
    this.large = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 7,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: large ? 13 : 11),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: large ? 11 : 9.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
