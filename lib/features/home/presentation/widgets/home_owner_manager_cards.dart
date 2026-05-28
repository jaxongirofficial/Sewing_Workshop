import 'package:flutter/material.dart';

import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_dashboard_hub_card.dart';
import '../../../workshop/models/workshop_mock_models.dart';
import 'home_section_title.dart';

class HomeOwnerManagerCards extends StatelessWidget {
  const HomeOwnerManagerCards({
    super.key,
    required this.attendance,
    required this.tasks,
    required this.onOpenAttendance,
    required this.onOpenTasks,
  });

  final List<PersonAttendance> attendance;
  final List<WorkshopTaskItem> tasks;
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final present = attendance.where((e) => e.present).length;
    final total = attendance.isEmpty ? 1 : attendance.length;
    final percent = ((present / total) * 100).round();
    final activeTasks = tasks.where((t) => !t.isDone).length;

    const gap = 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        HomeSectionTitle(title: s.hubSectionTitle),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BrandDashboardHubCard(
                  icon: Icons.co_present_rounded,
                  label: s.attendance,
                  value: s.attendanceRatio(present, total),
                  caption: s.todayAtWork,
                  chipLabel: s.metricsPercent(percent),
                  chipIcon: Icons.trending_up_rounded,
                  actionLabel: s.openAttendance,
                  onTap: onOpenAttendance,
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: BrandDashboardHubCard(
                  icon: Icons.work_rounded,
                  label: s.tasks,
                  value: '$activeTasks',
                  caption: s.activeRecords,
                  chipLabel: s.active,
                  chipIcon: Icons.bolt_rounded,
                  actionLabel: s.openTasks,
                  onTap: onOpenTasks,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
