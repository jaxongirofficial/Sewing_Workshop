import 'package:flutter/material.dart';

import '../../../../../config/theme/app_radius.dart';
import '../../../../../l10n/s.dart';
import '../../../../../shared/widgets/brand/brand_surface.dart';
import '../../models/workshop_mock_models.dart';
import 'task_labels.dart';

class TaskListTile extends StatelessWidget {
  const TaskListTile({super.key, required this.task});

  final WorkshopTaskItem task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);

    return BrandSurface(
      radius: AppRadius.md,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withValues(alpha: 0.20),
                  scheme.primary.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.30),
              ),
            ),
            child: Icon(
              Icons.task_alt_rounded,
              color: scheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizedTaskTitle(task, s),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.assigneeName,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
