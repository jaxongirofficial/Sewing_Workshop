import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/l10n/locale_provider.dart';
import '../../../../../config/theme/app_radius.dart';
import '../../../../../config/theme/theme_mode_provider.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../l10n/s.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../models/workshop_mock_models.dart';
import '../../providers/workshop_mock_providers.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/profile_language_picker_sheet.dart';
import '../../widgets/profile/profile_mini_stat.dart';
import '../../widgets/profile/profile_settings_card.dart';
import '../../widgets/profile/profile_theme_picker_sheet.dart';

class ProfileTabPage extends ConsumerWidget {
  const ProfileTabPage({super.key, required this.role});

  final UserRole role;

  String _roleLabel(S s, UserRole r) => switch (r) {
    UserRole.owner => s.roleOwner,
    UserRole.manager => s.roleManager,
    UserRole.worker => s.roleWorker,
  };

  String _languageLabel(S s, Locale locale) => switch (locale.languageCode) {
    'en' => s.languageEnglish,
    'ru' => s.languageRussian,
    _ => s.languageUzbek,
  };

  String _themeLabel(S s, ThemeMode mode) => switch (mode) {
    ThemeMode.light => s.themeLight,
    ThemeMode.dark => s.themeDark,
    ThemeMode.system => s.themeSystem,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);
    final user = ref.watch(authNotifierProvider).user;
    final attendance = ref.watch(attendanceProvider);
    final tasks = ref.watch(tasksProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    final mine = user;
    PersonAttendance? myAttendance;
    if (mine != null) {
      for (final item in attendance) {
        if (item.id == mine.id) {
          myAttendance = item;
          break;
        }
      }
    }
    final myTasksCount = mine == null
        ? 0
        : tasks.where((t) => t.assigneeId == mine.id).length;

    final initials = (user?.displayName ?? '?')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join()
        .toUpperCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        ProfileHeader(
          name: user?.displayName ?? s.userFallback,
          phone: user?.phone ?? '',
          roleLabel: _roleLabel(s, role),
          initials: initials.isEmpty ? '?' : initials,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ProfileMiniStat(
                icon: Icons.event_available_rounded,
                title: s.attendance,
                value: (myAttendance?.present ?? false) ? s.atWork : s.no,
                hint: myAttendance?.checkInTime ?? '-',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ProfileMiniStat(
                icon: Icons.assignment_turned_in_rounded,
                title: s.task,
                value: '$myTasksCount',
                hint: s.inList,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            s.settings,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
        ProfileSettingsCard(
          rows: [
            ProfileSettingRow(
              icon: Icons.shield_outlined,
              title: s.security,
              subtitle: s.passwordLoginHistory,
              onTap: () {},
            ),
            ProfileSettingRow(
              icon: Icons.notifications_none_rounded,
              title: s.notifications,
              subtitle: s.pushEmail,
              onTap: () {},
            ),
            ProfileSettingRow(
              icon: Icons.language_rounded,
              title: s.language,
              subtitle: _languageLabel(s, locale),
              onTap: () => showProfileLanguagePicker(context, ref, locale),
            ),
            ProfileSettingRow(
              icon: themeMode.icon,
              title: s.theme,
              subtitle: _themeLabel(s, themeMode),
              onTap: () => showProfileThemePicker(context, ref, themeMode),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ProfileSettingsCard(
          rows: [
            ProfileSettingRow(
              icon: Icons.help_outline_rounded,
              title: s.help,
              subtitle: s.faqGuide,
              onTap: () {},
            ),
            ProfileSettingRow(
              icon: Icons.info_outline_rounded,
              title: s.aboutApp,
              subtitle: s.appVersion,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
            icon: Icon(Icons.logout_rounded, color: scheme.error, size: 20),
            label: Text(
              s.signOut,
              style: textTheme.labelLarge?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: scheme.error.withValues(alpha: 0.35),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              backgroundColor: scheme.error.withValues(alpha: 0.04),
            ),
          ),
        ),
      ],
    );
  }
}
