import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/route_paths.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../l10n/s.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../providers/workshop_mock_providers.dart';
import '../../widgets/home/home_greeting_card.dart';
import '../../widgets/home/home_orders_section.dart';
import '../../widgets/home/home_owner_manager_cards.dart';
import '../../widgets/home/home_worker_cards.dart';
import '../../widgets/home/home_workers_card.dart';

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
    final orders = ref.watch(ordersProvider);
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
        HomeGreetingCard(name: firstName, subtitle: subtitle),
        const SizedBox(height: 20),
        if (role == UserRole.worker)
          HomeWorkerCards(
            user: user,
            attendance: attendance,
            tasks: tasks,
            onOpenAttendance: () => context.go(_attendancePath()),
            onOpenTasks: () => context.go(_tasksPath()),
          )
        else ...[
          HomeOwnerManagerCards(
            attendance: attendance,
            tasks: tasks,
            onOpenAttendance: () => context.go(_attendancePath()),
            onOpenTasks: () => context.go(_tasksPath()),
            onOpenWorkers: () => context.push(_workersPath()),
          ),
          const SizedBox(height: 14),
          HomeWorkersCard(
            workerCount: workers.length,
            onTap: () => context.push(_workersPath()),
            showAddButton: role == UserRole.owner,
            onAdd: role == UserRole.owner
                ? () => context.push(AppRoutes.ownerAddEmployee)
                : null,
          ),
          const SizedBox(height: 22),
          HomeOrdersSection(orders: orders),
        ],
      ],
    );
  }
}
