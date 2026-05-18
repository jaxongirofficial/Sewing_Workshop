import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/theme/app_radius.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../l10n/s.dart';
import '../../../../../shared/widgets/brand/brand_surface.dart';
import '../../../../../shared/widgets/brand/brand_switch_tile.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../models/workshop_mock_models.dart';
import '../../providers/workshop_mock_providers.dart';

/// Davomat — iOS uslubdagi switch bilan.
class AttendanceTabPage extends ConsumerWidget {
  const AttendanceTabPage({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);
    final user = ref.watch(authNotifierProvider).user;
    final list = ref.watch(attendanceProvider);

    late final List<PersonAttendance> rows;
    if (role == UserRole.worker && user != null) {
      rows = list.where((e) => e.id == user.id).toList();
    } else {
      rows = list.toList();
    }

    final hint = switch (role) {
      UserRole.worker => s.attendanceWorkerHint,
      UserRole.manager => s.attendanceManagerHint,
      UserRole.owner => s.attendanceOwnerHint,
    };

    final presentCount = rows.where((p) => p.present).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        BrandSurface(
          radius: AppRadius.lg,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
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
                      color: scheme.primary.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                      spreadRadius: -6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.how_to_reg_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.todayAtWorkSummary(
                        presentCount,
                        rows.isEmpty ? 1 : rows.length,
                      ),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hint,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...rows.map((p) {
          final canToggle =
              role != UserRole.worker || (user != null && p.id == user.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: BrandSwitchTile(
              leadingIcon: Icons.person_rounded,
              title: p.name,
              subtitle: p.present
                  ? (p.checkInTime != null
                      ? s.atWorkWithTime(p.checkInTime!)
                      : s.atWork)
                  : s.absent,
              value: p.present,
              enabled: canToggle,
              onChanged: canToggle
                  ? (_) => ref.read(attendanceProvider.notifier).toggle(p.id)
                  : null,
            ),
          );
        }),
      ],
    );
  }
}
