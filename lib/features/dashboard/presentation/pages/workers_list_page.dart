import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_radius.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_dashboard_backdrop.dart';
import '../../../../shared/widgets/brand/brand_surface.dart';
import '../providers/workshop_mock_providers.dart';
import '../widgets/workers/worker_tile.dart';
import '../widgets/workers/workers_empty_state.dart';
import '../widgets/workers/workers_header_summary.dart';

/// Jamoa / ishchilar to'liq ro'yxati.
class WorkersListPage extends ConsumerWidget {
  const WorkersListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);
    final workers = ref.watch(workshopWorkersProvider);

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
          body: SafeArea(
            top: false,
            child: workers.isEmpty
                ? const WorkersEmptyState()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
