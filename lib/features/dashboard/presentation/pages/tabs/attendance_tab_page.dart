import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/enums/user_role.dart';
import '../../../../../l10n/s.dart';
import '../../../../../shared/widgets/brand/brand_switch_tile.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../models/workshop_mock_models.dart';
import '../../providers/workshop_mock_providers.dart';
import '../../widgets/attendance/attendance_summary_card.dart';

/// Davomat — iOS uslubdagi switch bilan.
class AttendanceTabPage extends ConsumerWidget {
  const AttendanceTabPage({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final user = ref.watch(authNotifierProvider).user;
    final list = ref.watch(attendanceProvider);
    final employees = ref.watch(employeesProvider);
    final employeeById = {for (final e in employees) e.id: e};

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
        AttendanceSummaryCard(
          title: s.todayAtWorkSummary(
            presentCount,
            rows.isEmpty ? 1 : rows.length,
          ),
          hint: hint,
        ),
        const SizedBox(height: 18),
        ...rows.map((p) {
          final canToggle =
              role != UserRole.worker || (user != null && p.id == user.id);
          final emp = employeeById[p.id];
          final subtitleParts = <String>[];
          subtitleParts.add(
            p.present
                ? (p.checkInTime != null
                    ? s.atWorkWithTime(p.checkInTime!)
                    : s.atWork)
                : s.absent,
          );
          if (emp != null) {
            subtitleParts.add(
              emp.role == 'manager' ? s.roleManager : s.roleTailor,
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: BrandSwitchTile(
              leadingIcon: emp?.role == 'manager'
                  ? Icons.supervisor_account_rounded
                  : Icons.person_rounded,
              title: p.name,
              subtitle: subtitleParts.join(' • '),
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
