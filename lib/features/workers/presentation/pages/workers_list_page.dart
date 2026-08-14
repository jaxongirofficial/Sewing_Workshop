import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_paths.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_dashboard_backdrop.dart';
import '../../../../shared/widgets/brand/brand_surface.dart';
import '../providers/workers_provider.dart';
import '../widgets/worker_tile.dart';
import '../widgets/workers_header_summary.dart';

/// Jamoa / ishchilar to'liq ro'yxati.
class WorkersListPage extends ConsumerStatefulWidget {
  const WorkersListPage({super.key, this.role});

  final UserRole? role;

  @override
  ConsumerState<WorkersListPage> createState() => _WorkersListPageState();
}

class _WorkersListPageState extends ConsumerState<WorkersListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workersProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);
    final workersState = ref.watch(workersProvider);
    final workers = workersState.valueOrNull
            ?.map((worker) => worker.toWorkshopWorker())
            .toList(growable: false) ??
        const [];
    final canAddEmployee = widget.role == UserRole.owner;

    return Stack(
      fit: StackFit.expand,
      children: [
        const BrandDashboardBackdrop(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: scheme.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              s.workersList,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          floatingActionButton: canAddEmployee
              ? _AddEmployeeFab(
                  onTap: () => context.push(AppRoutes.ownerAddEmployee),
                )
              : null,
          body: SafeArea(
            top: false,
            child: workersState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : workers.isEmpty
                ? _EmptyWithAdd(
                    canAdd: canAddEmployee,
                    onAdd: () => context.push(AppRoutes.ownerAddEmployee),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                        20, 8, 20, canAddEmployee ? 96 : 24),
                    children: [
                      WorkersHeaderSummary(count: workers.length),
                      const SizedBox(height: 14),
                      BrandSurface(
                        radius: AppRadius.lg,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < workers.length; i++) ...[
                              WorkerTile(worker: workers[i]),
                              if (i != workers.length - 1)
                                Padding(
                                  padding: const EdgeInsets.only(left: 58),
                                  child: Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: scheme.outlineVariant
                                        .withValues(alpha: 0.45),
                                  ),
                                ),
                            ],
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

// ─── Beautiful FAB ────────────────────────────────────────────────────────────

class _AddEmployeeFab extends StatelessWidget {
  const _AddEmployeeFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              Color.lerp(
                scheme.primary,
                Colors.black,
                isDark ? 0.12 : 0.28,
              )!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.42),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              s.addEmployeeAction,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state with add prompt ─────────────────────────────────────────────

class _EmptyWithAdd extends StatelessWidget {
  const _EmptyWithAdd({required this.canAdd, required this.onAdd});

  final bool canAdd;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.1),
                border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.2), width: 2),
              ),
              child: Icon(
                Icons.groups_2_outlined,
                size: 38,
                color: scheme.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.workersEmpty,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              canAdd ? s.workersEmptyHint : s.workersEmptyHint,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
