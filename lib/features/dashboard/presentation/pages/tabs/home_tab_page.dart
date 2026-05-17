import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/theme/app_spacing.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../shared/widgets/atoms/app_card.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../models/workshop_mock_models.dart';
import '../../providers/workshop_mock_providers.dart';

/// Sodda bosh sahifa: salom + ko\'rsatkichlar.
class HomeTabPage extends ConsumerWidget {
  const HomeTabPage({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authNotifierProvider).user;
    final attendance = ref.watch(attendanceProvider);
    final tasks = ref.watch(tasksProvider);

    late final List<PersonAttendance> attRows;
    late final List<WorkshopTaskItem> taskRows;

    if (role == UserRole.worker && user != null) {
      attRows = attendance.where((e) => e.id == user.id).toList();
      taskRows = tasks.where((t) => t.assigneeId == user.id).toList();
    } else {
      attRows = attendance.toList();
      taskRows = tasks.toList();
    }

    final mineOnly = role == UserRole.worker && user != null;

    final present = attRows.where((e) => e.present).length;
    final totalAtt = attRows.isEmpty ? 1 : attRows.length;

    final subtitle = switch (role) {
      UserRole.owner =>
        'Umumiy ko\'rinish — davomat va topshiriqlarni pastki menyudan boshqiring.',
      UserRole.manager =>
        'Jamoa va liniya — davomatni yangilang, topshiriq bering.',
      UserRole.worker =>
        'Bugungi shift — davomatingiz va berilgan ishlar.',
    };

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Salom, ${user?.displayName ?? 'Mehmon'}',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                icon: Icons.groups_rounded,
                label: mineOnly ? 'Mening holatim' : 'Davomat',
                value: '$present / $totalAtt',
                caption:
                    mineOnly ? (present > 0 ? 'Bugun ishda' : 'Kelmagansiz') : 'Bugun ishda',
                accent: scheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MiniStat(
                icon: Icons.task_alt_rounded,
                label: mineOnly ? 'Topshiriqlarim' : 'Topshiriqlar',
                value: '${taskRows.length}',
                caption: mineOnly ? 'Ro\'yxatda' : 'Jami yozuv',
                accent: scheme.secondary,
              ),
            ),
          ],
        ),
        if (!mineOnly) ...[
          const SizedBox(height: AppSpacing.md),
          _MiniStat(
            icon: Icons.groups_outlined,
            label: 'Ishchilar (demo)',
            value: '${attendance.length}',
            caption: 'Davomat ro\'yxati',
            accent: scheme.tertiary,
            fullWidth: true,
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Pastki menyu',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Davomat — ishchilarni ishda/kelmagan qilib belgilash.\n'
          'Topshiriq — yangi vazifa berish (egasi va menejer).',
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    required this.accent,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final Color accent;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      hoverable: false,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: accent.withValues(alpha: 0.22),
      backgroundColor: scheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment:
            fullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            caption,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
