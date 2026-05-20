import 'package:flutter/material.dart';

import '../../../../../config/theme/app_radius.dart';
import '../../../../../l10n/s.dart';
import '../../../../../shared/widgets/brand/brand_surface.dart';
import '../../models/workshop_mock_models.dart';

class TaskListTile extends StatelessWidget {
  const TaskListTile({
    super.key,
    required this.task,
    this.canEdit = false,
    this.onEdit,
    this.onDelete,
    this.onUpdateProgress,
  });

  final WorkshopTaskItem task;
  final bool canEdit;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onUpdateProgress;

  Color _barColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (task.isDone) return Colors.green;
    if (task.isOverdue) return Colors.red;
    if (task.isUrgent) return Colors.orange;
    return scheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = _barColor(context);

    String? badge;
    Color badgeColor = barColor;
    if (task.isDone) {
      badge = s.taskDone;
    } else if (task.isOverdue) {
      badge = s.taskOverdue;
    } else if (task.isUrgent) {
      badge = s.taskUrgent;
    }

    return BrandSurface(
      radius: AppRadius.md,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: barColor.withValues(alpha: isDark ? 0.25 : 0.12),
                  border: Border.all(
                    color: barColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  task.isDone
                      ? Icons.check_circle_rounded
                      : Icons.task_alt_rounded,
                  color: barColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.productName,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isDone
                                  ? scheme.onSurface.withValues(alpha: 0.5)
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor
                                  .withValues(alpha: isDark ? 0.25 : 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badge,
                              style: textTheme.labelSmall?.copyWith(
                                color: badgeColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 13, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            task.assigneeName,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (task.deadline != null) ...[
                          Icon(Icons.schedule_rounded,
                              size: 13, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Text(
                            '${task.deadline!.day}.${task.deadline!.month.toString().padLeft(2, '0')}',
                            style: textTheme.bodySmall?.copyWith(
                              color: task.isOverdue
                                  ? Colors.red
                                  : scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (canEdit) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                  color: scheme.onSurfaceVariant,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  color: scheme.error,
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: task.progress,
                    backgroundColor:
                        scheme.onSurface.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                s.taskProgress(task.doneQty, task.targetQty),
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
              ),
            ],
          ),
          // Narx ma'lumotlari
          if (task.totalValue != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _PriceChip(
                    icon: Icons.receipt_long_outlined,
                    label: s.taskTotalValue(task.totalValue!.toInt()),
                    color: scheme.primary,
                    isDark: isDark,
                  ),
                ),
                if (task.earnedValue != null && task.doneQty > 0) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PriceChip(
                      icon: Icons.account_balance_wallet_outlined,
                      label: s.taskEarnedValue(task.earnedValue!.toInt()),
                      color: task.isDone ? Colors.green : barColor,
                      isDark: isDark,
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (onUpdateProgress != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onUpdateProgress,
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: Text(s.updateProgress),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.35 : 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
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
