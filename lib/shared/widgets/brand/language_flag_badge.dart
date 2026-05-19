import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

/// Dumaloq bayroq badge — tashqi va ichki qism ham circle.
class LanguageFlagBadge extends StatelessWidget {
  const LanguageFlagBadge({
    super.key,
    required this.languageCode,
    this.diameter = 48,
    this.selected = false,
  });

  final String languageCode;
  final double diameter;
  final bool selected;

  static String countryCodeFor(String languageCode) => switch (languageCode) {
        'en' => 'US',
        'ru' => 'RU',
        _ => 'UZ',
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderW = selected ? 2.4 : 1.1;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? scheme.primary
              : (isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.08)),
          width: borderW,
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? scheme.primary.withValues(alpha: 0.30)
                : Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
            blurRadius: selected ? 12 : 6,
            offset: Offset(0, selected ? 4 : 2),
            spreadRadius: -1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: CountryFlag.fromCountryCode(
        countryCodeFor(languageCode),
        theme: ImageTheme(
          width: diameter,
          height: diameter,
          shape: const Circle(),
        ),
      ),
    );
  }
}
