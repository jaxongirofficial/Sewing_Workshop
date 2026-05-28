import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_surface.dart';
import '../../../workshop/models/workshop_mock_models.dart';

class HomeTeamPreview extends StatelessWidget {
  const HomeTeamPreview({super.key, required this.rows, this.onTap});

  final List<PersonAttendance> rows;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);
    final preview = rows.take(4).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? scheme.surface : Colors.white;
    final borderColor = isDark
        ? scheme.outline.withValues(alpha: 0.35)
        : const Color(0xFFE6EBF4);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < preview.length; i++) ...[
                _TeamRow(p: preview[i]),
                if (i != preview.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 58),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: scheme.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
              ],
            ],
          ),
        ),
        if (onTap != null)
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: isDark ? 0.14 : 0.08),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.lg),
              ),
              border: Border(
                top: BorderSide(
                  color: scheme.primary.withValues(alpha: 0.12),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      s.openTeamList,
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withValues(alpha: 0.14),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    if (onTap == null) {
      return BrandSurface(
        radius: AppRadius.lg,
        padding: EdgeInsets.zero,
        child: content,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: scheme.primary.withValues(alpha: 0.10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            color: baseColor,
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.shadow.withValues(alpha: isDark ? 0.32 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -10,
              ),
            ],
          ),
          child: content,
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.p});

  final PersonAttendance p;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);
    final color = p.present ? scheme.primary : scheme.onSurfaceVariant;

    final initials = p.name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join()
        .toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color.withValues(alpha: 0.30)),
            ),
            alignment: Alignment.center,
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  p.present
                      ? (p.checkInTime != null
                          ? s.atWorkWithTime(p.checkInTime!)
                          : s.atWork)
                      : s.absent,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
