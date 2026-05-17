import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/enums/user_role.dart';

/// Pastki navigatsiya + AppBar — har bir rol uchun alohida shell.
class RoleShellScaffold extends StatelessWidget {
  const RoleShellScaffold({
    super.key,
    required this.role,
    required this.navigationShell,
  });

  final UserRole role;
  final StatefulNavigationShell navigationShell;

  static List<String> _titles(UserRole role) {
    final task = role == UserRole.worker ? 'Mening ishlarim' : 'Topshiriqlar';
    return [
      'Bosh sahifa',
      'Davomat',
      task,
      'Profil',
    ];
  }

  static List<NavigationDestination> _destinations(UserRole role) {
    final taskLabel = role == UserRole.worker ? 'Ishlarim' : 'Topshiriq';
    return [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Bosh',
      ),
      const NavigationDestination(
        icon: Icon(Icons.event_available_outlined),
        selectedIcon: Icon(Icons.event_available_rounded),
        label: 'Davomat',
      ),
      NavigationDestination(
        icon: const Icon(Icons.task_outlined),
        selectedIcon: const Icon(Icons.task_rounded),
        label: taskLabel,
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Profil',
      ),
    ];
  }

  Color _roleTint(ColorScheme scheme) => switch (role) {
        UserRole.owner => scheme.tertiary,
        UserRole.manager => scheme.secondary,
        UserRole.worker => scheme.primary,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final idx = navigationShell.currentIndex;
    final titles = _titles(role);
    final tint = _roleTint(scheme);

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[idx]),
        centerTitle: false,
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Icon(Icons.checkroom_rounded, color: tint, size: 26),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: navigationShell.goBranch,
        height: 72,
        elevation: 3,
        shadowColor: scheme.shadow.withValues(alpha: 0.12),
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: tint.withValues(alpha: 0.18),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _destinations(role),
      ),
    );
  }
}
