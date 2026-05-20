import 'package:flutter/material.dart';

import '../../../../../l10n/s.dart';
import '../../../../../shared/widgets/brand/brand_dashboard_hub_card.dart';
import '../../models/workshop_mock_models.dart';
import 'home_section_title.dart';

class HomeOwnerManagerCards extends StatelessWidget {
  const HomeOwnerManagerCards({
    super.key,
    required this.attendance,
    required this.tasks,
    required this.totalWorkers,
    required this.onOpenAttendance,
    required this.onOpenTasks,
    required this.onOpenWorkers,
  });

  final List<PersonAttendance> attendance;
  final List<WorkshopTaskItem> tasks;
  final int totalWorkers;
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenWorkers;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final present = attendance.where((e) => e.present).length;
    final total = attendance.isEmpty ? 1 : attendance.length;
    final percent = ((present / total) * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final side = (constraints.maxWidth - gap) / 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            HomeSectionTitle(title: s.hubSectionTitle),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: side,
                  height: side,
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
                SizedBox(
                  width: side,
                  height: side,
                  child: BrandDashboardHubCard(
                    icon: Icons.work_rounded,
                    label: s.tasks,
                    value: '${tasks.length}',
                    caption: s.activeRecords,
                    chipLabel: s.active,
                    chipIcon: Icons.bolt_rounded,
                    actionLabel: s.openTasks,
                    onTap: onOpenTasks,
                  ),
                ),
              ],
            ),
            const SizedBox(height: gap),
            SizedBox(
              width: double.infinity,
              child: BrandDashboardHubCard(
                fullWidth: true,
                icon: Icons.groups_2_rounded,
                label: s.team,
                value: '$totalWorkers',
                caption: s.workersList,
                chipLabel: s.workersCount(totalWorkers),
                chipIcon: Icons.people_alt_rounded,
                actionLabel: s.openTeamList,
                onTap: onOpenWorkers,
              ),
            ),
          ],
        );
      },
    );
  }
}
