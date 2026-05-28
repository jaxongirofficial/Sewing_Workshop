import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/l10n/locale_provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_scrollable_sheet.dart';
import '../../../../shared/widgets/brand/language_flag_badge.dart';

const _supportedLocales = <Locale>[
  Locale('uz'),
  Locale('en'),
  Locale('ru'),
];

Future<void> showProfileLanguagePicker(
  BuildContext context,
  WidgetRef ref,
  Locale current,
) async {
  final scheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final s = S.of(context);

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetCtx) {
      return BrandScrollableSheet(
        child: BrandSheetContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BrandSheetHandle(),
              const SizedBox(height: 16),
              Text(
                s.chooseLanguage,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.chooseLanguageHint,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              for (final locale in _supportedLocales) ...[
                _LanguageOption(
                  locale: locale,
                  selected: current.languageCode == locale.languageCode,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(locale);
                    Navigator.of(sheetCtx).pop();
                  },
                ),
                if (locale != _supportedLocales.last)
                  const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final Locale locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context);

    final title = switch (locale.languageCode) {
      'en' => s.languageEnglish,
      'ru' => s.languageRussian,
      _ => s.languageUzbek,
    };
    final hint = switch (locale.languageCode) {
      'en' => s.languageEnglishHint,
      'ru' => s.languageRussianHint,
      _ => s.languageUzbekHint,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: isDark ? 0.18 : 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected
                  ? scheme.primary.withValues(alpha: isDark ? 0.50 : 0.35)
                  : (isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.6)
                      : const Color(0xFFE6EBF4)),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              LanguageFlagBadge(
                languageCode: locale.languageCode,
                diameter: 48,
                selected: selected,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _CheckMark(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckMark extends StatelessWidget {
  const _CheckMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: selected
          ? Container(
              key: const ValueKey('language-on'),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    scheme.primary,
                    Color.lerp(scheme.primary, Colors.black, 0.18)!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              ),
            )
          : Container(
              key: const ValueKey('language-off'),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.30),
                  width: 1.4,
                ),
              ),
            ),
    );
  }
}
