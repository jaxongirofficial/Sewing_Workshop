import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/route_paths.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_radius.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../l10n/s.dart';
import '../../../../../shared/models/app_user.dart';
import '../../../../../shared/widgets/brand/brand_dashboard_hub_card.dart';
import '../../../../../shared/widgets/brand/brand_surface.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../models/workshop_mock_models.dart';
import '../../providers/workshop_mock_providers.dart';

String _localizedTaskTitle(WorkshopTaskItem task, S s) => switch (task.id) {
      't-1' => s.seedTaskDresses,
      't-2' => s.seedTaskQc,
      _ => task.title,
    };

/// Premium bosh sahifa — har bir rol uchun moslashtirilgan kartochkalar.
class HomeTabPage extends ConsumerWidget {
  const HomeTabPage({super.key, required this.role});

  final UserRole role;

  String _attendancePath() => switch (role) {
        UserRole.owner => AppRoutes.ownerAttendance,
        UserRole.manager => AppRoutes.managerAttendance,
        UserRole.worker => AppRoutes.workerAttendance,
      };

  String _tasksPath() => switch (role) {
        UserRole.owner => AppRoutes.ownerTasks,
        UserRole.manager => AppRoutes.managerTasks,
        UserRole.worker => AppRoutes.workerTasks,
      };

  String _workersPath() => switch (role) {
        UserRole.owner => AppRoutes.ownerWorkers,
        UserRole.manager => AppRoutes.managerWorkers,
        UserRole.worker => AppRoutes.workerHome,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final user = ref.watch(authNotifierProvider).user;
    final attendance = ref.watch(attendanceProvider);
    final tasks = ref.watch(tasksProvider);
    final workers = ref.watch(workshopWorkersProvider);

    final subtitle = switch (role) {
      UserRole.owner => s.ownerHomeSubtitle,
      UserRole.manager => s.managerHomeSubtitle,
      UserRole.worker => s.workerHomeSubtitle,
    };

    final firstName = (user?.displayName.trim().isNotEmpty ?? false)
        ? user!.displayName.trim().split(RegExp(r'\s+')).first
        : '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        _GreetingCard(name: firstName, subtitle: subtitle),
        const SizedBox(height: 20),
        if (role == UserRole.worker)
          _WorkerCards(
            user: user,
            attendance: attendance,
            tasks: tasks,
            onOpenAttendance: () => context.go(_attendancePath()),
            onOpenTasks: () => context.go(_tasksPath()),
          )
        else
          _OwnerManagerCards(
            attendance: attendance,
            tasks: tasks,
            totalWorkers: workers.length,
            onOpenAttendance: () => context.go(_attendancePath()),
            onOpenTasks: () => context.go(_tasksPath()),
            onOpenWorkers: () => context.push(_workersPath()),
          ),
        const SizedBox(height: 22),
        _SectionTitle(
          title: role == UserRole.worker ? s.myTasks : s.recentTasks,
          actionLabel: s.all,
          onAction: () => context.go(_tasksPath()),
        ),
        const SizedBox(height: 10),
        _TasksPreview(
          tasks: role == UserRole.worker && user != null
              ? tasks.where((t) => t.assigneeId == user.id).toList()
              : tasks,
          emptyText: role == UserRole.worker ? s.noAssignedTasks : s.noTasksYet,
        ),
        if (role != UserRole.worker) ...[
          const SizedBox(height: 22),
          _SectionTitle(
            title: s.teamStatus,
            actionLabel: s.fullList,
            onAction: () => context.push(_workersPath()),
          ),
          const SizedBox(height: 10),
          _TeamPreview(
            rows: attendance,
            onTap: () => context.push(_workersPath()),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);

    return BrandSurface(
      radius: AppRadius.xl,
      tinted: true,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary,
                  scheme.primary.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.36),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                  spreadRadius: -6,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.waving_hand_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name.isEmpty ? s.hello : s.helloName(name),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: scheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _OwnerManagerCards extends StatelessWidget {
  const _OwnerManagerCards({
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

    Widget squareCard({
      required Widget child,
      required double side,
    }) {
      return SizedBox(width: side, height: side, child: child);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final side = (constraints.maxWidth - gap) / 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SectionTitle(title: s.hubSectionTitle),
            const SizedBox(height: 10),
            Row(
              children: [
                squareCard(
                  side: side,
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
                squareCard(
                  side: side,
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

// ---------------------------------------------------------------------------

class _WorkerCards extends StatelessWidget {
  const _WorkerCards({
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
        _SectionTitle(title: s.hubSectionTitle),
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
                                        color:
                                            Colors.white.withValues(alpha: 0.88),
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
        LayoutBuilder(
          builder: (context, constraints) {
            final side = (constraints.maxWidth - 12) / 2;
            return Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: side,
                height: side,
                child: BrandDashboardHubCard(
                  icon: Icons.work_rounded,
                  label: s.myTasks,
                  value: '$myTasksCount',
                  caption: s.inList,
                  chipLabel: s.active,
                  chipIcon: Icons.bolt_rounded,
                  actionLabel: s.workerViewTasks,
                  onTap: onOpenTasks,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
                letterSpacing: -0.2,
                fontSize: 15,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: scheme.primary.withValues(alpha: 0.10),
                    border: Border.all(
                      color: scheme.primary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel!,
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _TasksPreview extends StatelessWidget {
  const _TasksPreview({required this.tasks, required this.emptyText});

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
                          _localizedTaskTitle(t, s),
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

// ---------------------------------------------------------------------------

class _TeamPreview extends StatelessWidget {
  const _TeamPreview({required this.rows, this.onTap});

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

    Widget buildCard({VoidCallback? tap}) {
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
          if (tap != null)
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

      if (tap == null) {
        return BrandSurface(
          radius: AppRadius.lg,
          padding: EdgeInsets.zero,
          child: content,
        );
      }

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: tap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          splashColor: scheme.primary.withValues(alpha: 0.10),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              color: baseColor,
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow
                      .withValues(alpha: isDark ? 0.32 : 0.06),
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

    return buildCard(tap: onTap);
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
