import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enums/user_role.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/dashboard/presentation/pages/add_employee_page.dart';
import '../../features/dashboard/presentation/pages/workers_list_page.dart';
import '../../features/dashboard/presentation/pages/tabs/attendance_tab_page.dart';
import '../../features/dashboard/presentation/pages/tabs/home_tab_page.dart';
import '../../features/dashboard/presentation/pages/tabs/profile_tab_page.dart';
import '../../features/dashboard/presentation/pages/tabs/tasks_tab_page.dart';
import '../../features/dashboard/presentation/pages/tabs/warehouse_tab_page.dart';
import '../../features/dashboard/presentation/shell/role_shell_scaffold.dart';
import 'route_paths.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(this._ref) {
    _ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) => notifyListeners(),
    );
  }

  final Ref _ref;
}

final authRouterRefreshProvider = Provider<AuthRouterRefresh>((ref) {
  final notifier = AuthRouterRefresh(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

String dashboardLocationForRole(UserRole role) => switch (role) {
      UserRole.owner => AppRoutes.ownerHome,
      UserRole.manager => AppRoutes.managerHome,
      UserRole.worker => AppRoutes.workerHome,
    };

String rolePrefix(UserRole role) => switch (role) {
      UserRole.owner => '/owner',
      UserRole.manager => '/manager',
      UserRole.worker => '/worker',
    };

StatefulShellRoute _ownerShell() {
  return StatefulShellRoute.indexedStack(
    builder: (context, _, shell) {
      return RoleShellScaffold(role: UserRole.owner, navigationShell: shell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.ownerHome,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const HomeTabPage(role: UserRole.owner),
                ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.ownerAttendance,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const AttendanceTabPage(role: UserRole.owner),
                ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.ownerTasks,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const TasksTabPage(role: UserRole.owner),
                ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.ownerWarehouse,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const WarehouseTabPage(role: UserRole.owner),
                ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.ownerProfile,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const ProfileTabPage(role: UserRole.owner),
                ),
          ),
        ],
      ),
    ],
  );
}

StatefulShellRoute _managerShell() {
  return StatefulShellRoute.indexedStack(
    builder: (context, _, shell) {
      return RoleShellScaffold(role: UserRole.manager, navigationShell: shell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.managerHome,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const HomeTabPage(role: UserRole.manager),
                ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.managerAttendance,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const AttendanceTabPage(role: UserRole.manager),
                ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.managerTasks,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const TasksTabPage(role: UserRole.manager),
                ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.managerWarehouse,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const WarehouseTabPage(role: UserRole.manager),
                ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.managerProfile,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const ProfileTabPage(role: UserRole.manager),
                ),
          ),
        ],
      ),
    ],
  );
}

StatefulShellRoute _workerShell() {
  return StatefulShellRoute.indexedStack(
    builder: (context, _, shell) {
      return RoleShellScaffold(role: UserRole.worker, navigationShell: shell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.workerHome,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const HomeTabPage(role: UserRole.worker),
                ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.workerAttendance,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const AttendanceTabPage(role: UserRole.worker),
                ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.workerTasks,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const TasksTabPage(role: UserRole.worker),
                ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.workerWarehouse,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const WarehouseTabPage(role: UserRole.worker),
                ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.workerProfile,
            pageBuilder: (c, s) => NoTransitionPage<void>(
                  key: s.pageKey,
                  child: const ProfileTabPage(role: UserRole.worker),
                ),
          ),
        ],
      ),
    ],
  );
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(authRouterRefreshProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.uri.path;

      if (loc == AppRoutes.legacyOwnerDashboard) return AppRoutes.ownerHome;
      if (loc == AppRoutes.legacyManagerDashboard) return AppRoutes.managerHome;
      if (loc == AppRoutes.legacyWorkerDashboard) return AppRoutes.workerHome;

      final auth = ref.read(authNotifierProvider);

      if (auth.isAuthenticated) {
        final user = auth.user!;
        final prefix = rolePrefix(user.role);

        if (loc == AppRoutes.splash || loc == AppRoutes.login) {
          return dashboardLocationForRole(user.role);
        }

        final onRoleBranch =
            loc.startsWith('/owner') ||
                loc.startsWith('/manager') ||
                loc.startsWith('/worker');
        if (onRoleBranch && !loc.startsWith(prefix)) {
          return dashboardLocationForRole(user.role);
        }
      } else {
        final allowed = AppRoutes.isPublicRoute(loc);
        if (!allowed) return AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      _ownerShell(),
      _managerShell(),
      _workerShell(),
      GoRoute(
        path: AppRoutes.ownerAddEmployee,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          fullscreenDialog: true,
          child: const AddEmployeePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.ownerWorkers,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const WorkersListPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.managerWorkers,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const WorkersListPage(),
        ),
      ),
    ],
  );
});
