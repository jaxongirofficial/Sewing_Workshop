import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/theme/app_radius.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../l10n/s.dart';
import '../../../../../shared/widgets/brand/brand_surface.dart';
import '../../../../../shared/widgets/brand/brand_switch_tile.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../providers/workshop_mock_providers.dart';
import '../../widgets/attendance/attendance_summary_card.dart';

/// Davomat — sana filtri va iOS uslubdagi switch bilan.
class AttendanceTabPage extends ConsumerStatefulWidget {
  const AttendanceTabPage({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<AttendanceTabPage> createState() => _AttendanceTabPageState();
}

class _AttendanceTabPageState extends ConsumerState<AttendanceTabPage> {
  DateTime _selectedDate = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool get _isToday => _isSameDay(_selectedDate, DateTime.now());

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _shortDate(DateTime d) {
    final s = S.of(context);
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(d, now)) return s.dateFilterToday;
    if (_isSameDay(d, yesterday)) return s.dateFilterYesterday;
    return '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authNotifierProvider).user;
    final list = ref.watch(attendanceProvider);
    final employees = ref.watch(employeesProvider);
    final employeeById = {for (final e in employees) e.id: e};

    final allRows = widget.role == UserRole.worker && user != null
        ? list.where((e) => e.id == user.id).toList()
        : list.toList();

    // Demo: faqat bugun uchun haqiqiy ma'lumot, qolgan kunlar bo'sh

    final hint = switch (widget.role) {
      UserRole.worker => s.attendanceWorkerHint,
      UserRole.manager => s.attendanceManagerHint,
      UserRole.owner => s.attendanceOwnerHint,
    };

    final presentCount = (_isToday ? allRows : allRows)
        .where((p) => p.present)
        .length;

    final now = DateTime.now();
    final dateChips = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return d;
    });

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // ─── Date strip ───────────────────────────────────────────────────────
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dateChips.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              if (i == dateChips.length) {
                // "Sana tanlash" tugmasi
                return GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest
                          .withValues(alpha: isDark ? 0.4 : 0.6),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            size: 18, color: scheme.primary),
                        const SizedBox(height: 2),
                        Text(
                          s.dateFilterSelectDate,
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final d = dateChips[i];
              final isSelected = _isSameDay(d, _selectedDate);
              final isToday = _isSameDay(d, now);
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? scheme.primary
                        : scheme.surfaceContainerHighest
                            .withValues(alpha: isDark ? 0.4 : 0.6),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isSelected
                          ? scheme.primary
                          : scheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekdayShort(d),
                        style: textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${d.day}',
                        style: textTheme.titleSmall?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : scheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (isToday)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.white
                                : scheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        AttendanceSummaryCard(
          title: s.todayAtWorkSummary(
            presentCount,
            allRows.isEmpty ? 1 : allRows.length,
          ),
          hint: hint,
        ),
        const SizedBox(height: 18),
        if (!_isToday)
          BrandSurface(
            radius: AppRadius.md,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.history_rounded,
                    size: 32,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(height: 8),
                Text(
                  '${_shortDate(_selectedDate)} — ${s.attendanceDateHint}',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...allRows.map((p) {
            final canToggle = widget.role != UserRole.worker ||
                (user != null && p.id == user.id);
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
                    ? (_) =>
                        ref.read(attendanceProvider.notifier).toggle(p.id)
                    : null,
              ),
            );
          }),
      ],
    );
  }

  String _weekdayShort(DateTime d) {
    const days = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
    return days[d.weekday - 1];
  }
}
