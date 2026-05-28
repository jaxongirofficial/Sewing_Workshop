import 'package:flutter/material.dart';

import '../../../../config/theme/app_radius.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_surface.dart';
import '../../../workshop/models/workshop_mock_models.dart';

String localizedTaskTitle(WorkshopTaskItem task, S s) => task.productName;

class HomeTasksPreview extends StatelessWidget {
  const HomeTasksPreview({
    super.key,
    required this.tasks,
    required this.emptyText,
  });

  final List<WorkshopTaskItem> tasks;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);

    if (tasks.isEmpty) {
      return BrandSurface(
        radius: AppRadius.lg,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_rounded,
                size: 40,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 10),
              Text(
                emptyText,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final preview = tasks.take(3).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final t in preview)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: BrandSurface(
              radius: AppRadius.md,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary.withValues(alpha: 0.22),
                          scheme.primary.withValues(alpha: 0.08),
                        ],
                      ),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Icon(
                      Icons.task_alt_rounded,
                      color: scheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          localizedTaskTitle(t, s),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 13,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                t.assigneeName,
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
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
                ],
              ),
            ),
          ),
      ],
    );
  }
}
