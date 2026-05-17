import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Yagona brend rangi atrofida qurilgan tema. Hamma ekranlar shu bilan ishlaydi.
abstract final class AppTheme {
  static const double _inputHeight = 60;

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.brand,
      onPrimary: Colors.white,
      primaryContainer: AppColors.brandSoft,
      onPrimaryContainer: AppColors.brandDeep,
      secondary: AppColors.brandDeep,
      onSecondary: Colors.white,
      tertiary: AppColors.brand,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.panel,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.slate,
      outline: AppColors.stroke,
      outlineVariant: AppColors.strokeSoft,
      shadow: AppColors.shadow,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.panelMuted,
      surfaceContainer: const Color(0xFFF5F7FC),
      surfaceContainerHigh: const Color(0xFFF0F4FB),
      surfaceContainerHighest: const Color(0xFFE8EEF8),
    );

    return _build(
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBg: AppColors.dashboardBackdrop,
      overlay: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      inputFill: Colors.white,
      inputBorder: AppColors.stroke,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF8AA3FF),
      onPrimary: const Color(0xFF0B1426),
      primaryContainer: const Color(0xFF233A7C),
      onPrimaryContainer: const Color(0xFFE7EDFF),
      secondary: const Color(0xFFA6B8FF),
      onSecondary: const Color(0xFF0B1426),
      tertiary: const Color(0xFF8AA3FF),
      onTertiary: const Color(0xFF0B1426),
      error: const Color(0xFFFF8480),
      onError: const Color(0xFF1A0608),
      surface: AppColors.darkSurface,
      onSurface: const Color(0xFFF1F5FB),
      onSurfaceVariant: const Color(0xFFB7C1D4),
      outline: const Color(0xFF34405B),
      outlineVariant: const Color(0xFF263049),
      shadow: Colors.black,
      surfaceContainerLowest: const Color(0xFF0D1422),
      surfaceContainerLow: const Color(0xFF111A2C),
      surfaceContainer: const Color(0xFF152035),
      surfaceContainerHigh: const Color(0xFF1B273F),
      surfaceContainerHighest: const Color(0xFF22304A),
    );

    return _build(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBg: AppColors.dashboardBackdropDark,
      overlay: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      inputFill: const Color(0xFF182335),
      inputBorder: const Color(0xFF2A3955),
    );
  }

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Brightness brightness,
    required Color scaffoldBg,
    required SystemUiOverlayStyle overlay,
    required Color inputFill,
    required Color inputBorder,
  }) {
    final base = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withValues(alpha: 0.22),
        selectionHandleColor: colorScheme.primary,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        systemOverlayStyle: overlay,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surface,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        constraints: const BoxConstraints(minHeight: _inputHeight),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          minimumSize: const WidgetStatePropertyAll(Size(0, 56)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? colorScheme.primary.withValues(alpha: 0.35)
                : colorScheme.primary,
          ),
          foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outline),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(colorScheme.primary),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.primary.withValues(alpha: 0.10),
        selectedColor: colorScheme.primary.withValues(alpha: 0.18),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.25),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        labelStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.surface,
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
        elevation: 0,
      ),
    );

    return base.copyWith(
      textTheme: AppTextStyles.textTheme(base.textTheme),
      shadowColor: brightness == Brightness.light
          ? AppColors.shadow.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.4),
    );
  }
}
