import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/theme/app_spacing.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../shared/widgets/atoms/app_card.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';

class ProfileTabPage extends ConsumerWidget {
  const ProfileTabPage({super.key, required this.role});

  final UserRole role;

  Color _accent(ColorScheme scheme) => switch (role) {
        UserRole.owner => scheme.tertiary,
        UserRole.manager => scheme.secondary,
        UserRole.worker => scheme.primary,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authNotifierProvider).user;
    final accent = _accent(scheme);

    final initials = (user?.displayName ?? '?')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join()
        .toUpperCase();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        AppCard(
          hoverable: false,
          padding: const EdgeInsets.all(AppSpacing.xl),
          borderColor: accent.withValues(alpha: 0.28),
          backgroundColor: scheme.surfaceContainerLow,
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: accent.withValues(alpha: 0.18),
                foregroundColor: accent,
                child: Text(
                  initials.isEmpty ? '?' : initials,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                user?.displayName ?? 'Foydalanuvchi',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                user?.phone ?? '',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Chip(
                label: Text(role.displayLabel),
                backgroundColor: accent.withValues(alpha: 0.14),
                side: BorderSide(color: accent.withValues(alpha: 0.35)),
                labelStyle: textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.tonalIcon(
          onPressed: () =>
              ref.read(authNotifierProvider.notifier).signOut(),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Chiqish'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      ],
    );
  }
}
