import 'package:flutter/material.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_radius.dart';
import '../../../../../l10n/s.dart';
import '../../../../../shared/models/app_user.dart';
import '../../../../../shared/widgets/brand/brand_dashboard_hub_card.dart';
import '../../models/workshop_mock_models.dart';
import 'home_section_title.dart';

class HomeWorkerCards extends StatelessWidget {
  const HomeWorkerCards({
    super.key,
    required this.user,
    required this.attendance,
    required this.tasks,
    required this.onOpenAttendance,
    required this.onOpenTasks,
  });

  final AppUser? user;
  final List<PersonAttendance> attendance;
  final List<WorkshopTaskItem> tasks;
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);

    PersonAttendance? me;
    if (user != null) {
      for (final a in attendance) {
        if (a.id == user!.id) {
          me = a;
          break;
        }
      }
    }
    final present = me?.present ?? false;
    final time = me?.checkInTime;
    final myTasksCount = user == null
        ? 0
        : tasks.where((t) => t.assigneeId == user!.id).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        HomeSectionTitle(title: s.hubSectionTitle),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onOpenAttendance,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: present
                      ? [
                          scheme.primary,
                          Color.lerp(scheme.primary, AppColors.brandDeep, 0.6)!,
                        ]
                      : [
                          const Color(0xFF6B7585),
                          const Color(0xFF445065),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (present ? scheme.primary : Colors.black)
                        .withValues(alpha: 0.30),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45),
                              width: 1.4,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            present ? Icons.check_rounded : Icons.close_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s.todayStatus,
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.80),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  fontSize: 10.5,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                present ? s.atWork : s.notAtWork,
                                style: textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    color: Colors.white.withValues(alpha: 0.88),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      present
                                          ? (time != null
                                              ? s.entryTime(time)
                                              : s.noTime)
                                          : s.notArrivedYet,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Colors.white
                                            .withValues(alpha: 0.88),
                                        fontWeight: FontWeight.w600,
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
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(AppRadius.xl),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.workerUpdateStatus,
                              style: textTheme.labelLarge?.copyWith(
                                color: Colors.white,
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
                              color: Colors.white.withValues(alpha: 0.20),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        BrandDashboardHubCard(
          fullWidth: true,
          icon: Icons.work_rounded,
          label: s.myTasks,
          value: '$myTasksCount',
          caption: s.inList,
          chipLabel: s.active,
          chipIcon: Icons.bolt_rounded,
          actionLabel: s.workerViewTasks,
          onTap: onOpenTasks,
        ),
      ],
    );
  }
}
