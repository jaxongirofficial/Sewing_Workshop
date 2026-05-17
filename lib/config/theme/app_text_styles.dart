import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale built on Material 3 text theme with a premium sans family.
abstract final class AppTextStyles {
  static TextTheme textTheme(TextTheme base) {
    final manrope = GoogleFonts.manropeTextTheme(base);
    return manrope.copyWith(
      displaySmall: manrope.displaySmall?.copyWith(
        fontSize: 36,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.1,
      ),
      headlineLarge: manrope.headlineLarge?.copyWith(
        fontSize: 32,
        height: 1.14,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.9,
      ),
      headlineMedium: manrope.headlineMedium?.copyWith(
        fontSize: 28,
        height: 1.18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      headlineSmall: manrope.headlineSmall?.copyWith(
        fontSize: 24,
        height: 1.24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      titleLarge: manrope.titleLarge?.copyWith(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: manrope.titleMedium?.copyWith(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleSmall: manrope.titleSmall?.copyWith(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: manrope.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.55,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: manrope.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.55,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: manrope.bodySmall?.copyWith(
        fontSize: 13,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: manrope.labelLarge?.copyWith(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      labelMedium: manrope.labelMedium?.copyWith(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelSmall: manrope.labelSmall?.copyWith(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.35,
      ),
    );
  }

  static TextStyle kpiValue(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle kpiLabel(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.labelLarge!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
  }

  static Color brandMuted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.72);
}
