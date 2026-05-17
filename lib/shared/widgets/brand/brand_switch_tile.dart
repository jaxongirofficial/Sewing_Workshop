import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_radius.dart';
import 'brand_surface.dart';

/// iOS uslubidagi switch bilan birga turuvchi qator. Davomat ekranida ishlatiladi.
class BrandSwitchTile extends StatelessWidget {
  const BrandSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.leadingIcon,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? leadingIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BrandSurface(
      radius: AppRadius.md,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap:
          enabled && onChanged != null ? () => onChanged!(!value) : null,
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            _LeadingBadge(
              icon: leadingIcon!,
              active: value,
              color: scheme.primary,
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: value
                            ? scheme.primary
                            : scheme.onSurfaceVariant.withValues(alpha: 0.45),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IgnorePointer(
            ignoring: !enabled,
            child: Opacity(
              opacity: enabled ? 1 : 0.45,
              child: CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: scheme.primary,
                inactiveTrackColor:
                    scheme.onSurfaceVariant.withValues(alpha: 0.32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadingBadge extends StatelessWidget {
  const _LeadingBadge({
    required this.icon,
    required this.active,
    required this.color,
  });

  final IconData icon;
  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: active
              ? [
                  color.withValues(alpha: 0.95),
                  color.withValues(alpha: 0.65),
                ]
              : [
                  color.withValues(alpha: 0.18),
                  color.withValues(alpha: 0.08),
                ],
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                  spreadRadius: -6,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: active ? Colors.white : color,
        size: 22,
      ),
    );
  }
}
