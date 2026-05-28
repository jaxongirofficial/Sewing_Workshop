import 'package:flutter/material.dart';

import '../../../../l10n/s.dart';
import '../../../workshop/models/workshop_mock_models.dart';

class WorkerTile extends StatelessWidget {
  const WorkerTile({super.key, required this.worker});

  final WorkshopWorker worker;

  String _roleLabel(S s) => switch (worker.role) {
    'manager' => s.roleManager,
    'worker' => s.roleTailor,
    _ => s.roleWorker,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);

    final atWork = worker.present == true;
    final statusColor = worker.present == null
        ? scheme.onSurfaceVariant
        : (atWork ? scheme.primary : scheme.onSurfaceVariant);

    final initials = worker.name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join()
        .toUpperCase();

    final statusText = worker.present == null
        ? null
        : (atWork
            ? (worker.checkInTime != null
                ? s.atWorkWithTime(worker.checkInTime!)
                : s.atWork)
            : s.absent);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.14),
              border: Border.all(color: statusColor.withValues(alpha: 0.32)),
            ),
            alignment: Alignment.center,
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: statusColor,
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
                  worker.name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (worker.phone != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_iphone_rounded,
                        size: 12,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          worker.phone!,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (statusText != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          statusText,
                          style: textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (worker.role != null) ...[
            const SizedBox(width: 8),
            _RoleBadge(label: _roleLabel(s)),
          ],
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: scheme.primary.withValues(alpha: 0.10),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: scheme.primary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
