import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/theme/app_spacing.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../shared/widgets/atoms/app_card.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../models/workshop_mock_models.dart';
import '../../providers/workshop_mock_providers.dart';

/// Ishda / kelmagan holatini almashtirish (mock, lokal).
class AttendanceTabPage extends ConsumerWidget {
  const AttendanceTabPage({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authNotifierProvider).user;
    final list = ref.watch(attendanceProvider);

    late final List<PersonAttendance> rows;
    if (role == UserRole.worker && user != null) {
      rows = list.where((e) => e.id == user.id).toList();
    } else {
      rows = list.toList();
    }

    final hint = switch (role) {
      UserRole.worker =>
        'Faqat o\'zingizni belgilashingiz mumkin. Kirish/chiqish vaqti demo.',
      UserRole.manager =>
        'Liniya ishchilari — ishda yoki yo\'qligini belgilang.',
      UserRole.owner => 'Barcha ishchilar holati (demo ma\'lumot).',
    };

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          hint,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...rows.map((p) {
          final canToggle = role != UserRole.worker ||
              (user != null && p.id == user.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              hoverable: false,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: SwitchListTile.adaptive(
                value: p.present,
                activeThumbColor: scheme.primary,
                activeTrackColor: scheme.primary.withValues(alpha: 0.35),
                title: Text(
                  p.name,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  p.present
                      ? 'Ishda${p.checkInTime != null ? ' • ${p.checkInTime}' : ''}'
                      : 'Kelmagan',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                onChanged: canToggle
                    ? (_) =>
                        ref.read(attendanceProvider.notifier).toggle(p.id)
                    : null,
              ),
            ),
          );
        }),
      ],
    );
  }
}
