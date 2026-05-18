import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_bottom_bar.dart';
import '../../../../shared/widgets/brand/brand_dashboard_backdrop.dart';

/// Yagona brand-dizayndagi shell — har bir rol uchun.
class RoleShellScaffold extends StatelessWidget {
  const RoleShellScaffold({
    super.key,
    required this.role,
    required this.navigationShell,
  });

  final UserRole role;
  final StatefulNavigationShell navigationShell;

  static String _greetingTitle(S s, UserRole role, int idx) {
    final task = role == UserRole.worker ? s.myTasks : s.tasks;
    return switch (idx) {
      0 => s.homePage,
      1 => s.attendance,
      2 => task,
      3 => s.warehouse,
      _ => s.profile,
    };
  }

  static String _roleSubtitle(S s, UserRole role) => switch (role) {
        UserRole.owner => s.roleOwner,
        UserRole.manager => s.roleManager,
        UserRole.worker => s.roleWorker,
      };

  static List<BrandNavItem> _items(S s, UserRole role) {
    final taskLabel = role == UserRole.worker ? s.myTasks : s.task;
    return [
      BrandNavItem(
        icon: Icons.space_dashboard_outlined,
        activeIcon: Icons.space_dashboard_rounded,
        label: s.home,
      ),
      BrandNavItem(
        icon: Icons.event_available_outlined,
        activeIcon: Icons.event_available_rounded,
        label: s.attendance,
      ),
      BrandNavItem(
        icon: Icons.work_outline_rounded,
        activeIcon: Icons.work_rounded,
        label: taskLabel,
      ),
      BrandNavItem(
        icon: Icons.warehouse_outlined,
        activeIcon: Icons.warehouse_rounded,
        label: s.warehouse,
      ),
      BrandNavItem(
        icon: Icons.account_circle_outlined,
        activeIcon: Icons.account_circle_rounded,
        label: s.profile,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context);
    final idx = navigationShell.currentIndex;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final overlay = isDark
        ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
        : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);

    /// Kontent suzuvchi dock ostida kesilmasligi uchun pastdan reserve.
    final dockReserve = bottomInset + 96;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const BrandDashboardBackdrop(),
          Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(74),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (isDark ? scheme.surface : Colors.white)
                              .withValues(alpha: 0.55),
                          (isDark ? scheme.surface : Colors.white)
                              .withValues(alpha: 0.20),
                        ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: scheme.outline.withValues(
                            alpha: isDark ? 0.30 : 0.14,
                          ),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _greetingTitle(s, role, idx),
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                      color: scheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _roleSubtitle(s, role),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    scheme.primary,
                                    Color.lerp(
                                      scheme.primary,
                                      Colors.black,
                                      isDark ? 0.10 : 0.25,
                                    )!,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: scheme.primary.withValues(alpha: 0.32),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                    spreadRadius: -6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.checkroom_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.only(bottom: dockReserve),
              child: navigationShell,
            ),
            bottomNavigationBar: BrandBottomBar(
              currentIndex: idx,
              onSelect: navigationShell.goBranch,
              items: _items(s, role),
            ),
          ),
        ],
      ),
    );
  }
}
