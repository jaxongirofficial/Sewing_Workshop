import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/route_paths.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_radius.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../l10n/s.dart';
import '../../../../../shared/models/app_user.dart';
import '../../../../../shared/widgets/brand/brand_stat_card.dart';
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
            role: role,
            attendance: attendance,
            tasks: tasks,
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
    required this.role,
    required this.attendance,
    required this.tasks,
    required this.onOpenAttendance,
    required this.onOpenTasks,
    required this.onOpenWorkers,
  });

  final UserRole role;
  final List<PersonAttendance> attendance;
  final List<WorkshopTaskItem> tasks;
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenWorkers;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final present = attendance.where((e) => e.present).length;
    final total = attendance.isEmpty ? 1 : attendance.length;
    final percent = ((present / total) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SectionTitle(title: s.todayMetrics),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: BrandStatCard(
                icon: Icons.co_present_rounded,
                label: s.attendance,
                value: '$present / $total',
                caption: s.todayAtWork,
                trailing: BrandStatChip(
                  icon: Icons.trending_up_rounded,
                  label: '$percent%',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BrandStatCard(
                icon: Icons.work_rounded,
                label: s.tasks,
                value: '${tasks.length}',
                caption: s.activeRecords,
                trailing: BrandStatChip(
                  icon: Icons.bolt_rounded,
                  label: s.active,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BrandStatCard(
          icon: Icons.groups_2_rounded,
          label: s.team,
          value: '${attendance.length}',
          caption: s.workersList,
          fullWidth: true,
          onTap: onOpenWorkers,
          trailing: BrandStatChip(
            icon: Icons.chevron_right_rounded,
            label: s.fullList,
          ),
        ),
        const SizedBox(height: 18),
        _SectionTitle(title: s.quickActions),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.fact_check_rounded,
                title: s.attendance,
                subtitle: s.mark,
                onTap: onOpenAttendance,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAction(
                icon: Icons.add_task_rounded,
                title: s.task,
                subtitle: role == UserRole.owner ? s.createNew : s.distribute,
                onTap: onOpenTasks,
              ),
            ),
          ],
        ),
      ],
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
        Container(
          padding: const EdgeInsets.all(20),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.white.withValues(alpha: 0.88),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            present
                                ? (time != null ? s.entryTime(time) : s.noTime)
                                : s.notArrivedYet,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
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
              const SizedBox(width: 8),
              Material(
                color: Colors.white.withValues(alpha: 0.18),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onOpenAttendance,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: BrandStatCard(
                icon: Icons.work_rounded,
                label: s.tasks,
                value: '$myTasksCount',
                caption: s.inList,
                trailing: BrandStatChip(
                  icon: Icons.bolt_rounded,
                  label: s.active,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAction(
                icon: Icons.list_alt_rounded,
                title: s.myTasks,
                subtitle: s.goToList,
                onTap: onOpenTasks,
              ),
            ),
          ],
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
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: scheme.primary,
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BrandSurface(
      radius: AppRadius.lg,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary,
                  Color.lerp(
                      scheme.primary, Colors.black, isDark ? 0.05 : 0.15)!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.55),
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
    final preview = rows.take(4).toList();
    final surface = BrandSurface(
      radius: AppRadius.lg,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );

    if (onTap == null) return surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: surface,
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
