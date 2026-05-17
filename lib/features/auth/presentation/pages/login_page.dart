import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../providers/auth_notifier.dart';
import '../widgets/login_form.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final notifier = ref.read(authNotifierProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final overlayStyle = isDark
        ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
        : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _LoginBackdrop(isDark: isDark, scheme: scheme),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        _PremiumLogo(isDark: isDark, scheme: scheme),
                        SizedBox(height: AppSpacing.xxxl + AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          scheme.surface.withValues(alpha: 0.52),
                                          scheme.surface.withValues(alpha: 0.38),
                                        ]
                                      : [
                                          Colors.white.withValues(alpha: 0.82),
                                          Colors.white.withValues(alpha: 0.62),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: isDark
                                      ? scheme.outline.withValues(alpha: 0.35)
                                      : Colors.white.withValues(alpha: 0.95),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow.withValues(
                                      alpha: isDark ? 0.45 : 0.09,
                                    ),
                                    blurRadius: isDark ? 40 : 48,
                                    offset: const Offset(0, 22),
                                    spreadRadius: -8,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xl,
                                  AppSpacing.xxl,
                                  AppSpacing.xl,
                                  AppSpacing.xl + AppSpacing.sm,
                                ),
                                child: LoginForm(
                                  isSubmitting: auth.isLoading,
                                  errorText: auth.errorMessage,
                                  onSubmit: ({required phone, required password}) async {
                                    await notifier.signIn(
                                      phone: phone,
                                      password: password,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginBackdrop extends StatelessWidget {
  const _LoginBackdrop({
    required this.isDark,
    required this.scheme,
  });

  final bool isDark;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.dashboardBackdropDark,
                      Color.lerp(AppColors.dashboardBackdropDark, scheme.primary, 0.12)!,
                      const Color(0xFF0A1628),
                    ]
                  : [
                      AppColors.loginBackdropTop,
                      AppColors.loginGlow.withValues(alpha: 0.55),
                      AppColors.loginBackdropBottom,
                    ],
            ),
          ),
        ),
        Positioned(
          right: -80,
          top: -60,
          child: _GlowOrb(
            diameter: 260,
            colors: [
              scheme.primary.withValues(alpha: isDark ? 0.22 : 0.28),
              scheme.primary.withValues(alpha: 0),
            ],
          ),
        ),
        Positioned(
          left: -90,
          bottom: 80,
          child: _GlowOrb(
            diameter: 280,
            colors: [
              scheme.secondary.withValues(alpha: isDark ? 0.14 : 0.18),
              scheme.secondary.withValues(alpha: 0),
            ],
          ),
        ),
        Positioned(
          left: 40,
          top: 140,
          child: _GlowOrb(
            diameter: 140,
            colors: [
              AppColors.loginGlowSecondary.withValues(alpha: isDark ? 0.08 : 0.35),
              Colors.transparent,
            ],
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.diameter,
    required this.colors,
  });

  final double diameter;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: colors,
            stops: const [0.25, 1],
          ),
        ),
      ),
    );
  }
}

class _PremiumLogo extends StatelessWidget {
  const _PremiumLogo({
    required this.isDark,
    required this.scheme,
  });

  final bool isDark;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final ring = BoxDecoration(
      shape: BoxShape.circle,
      gradient: SweepGradient(
        colors: [
          scheme.primary,
          scheme.secondary,
          scheme.tertiary,
          scheme.primary,
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: scheme.primary.withValues(alpha: isDark ? 0.35 : 0.25),
          blurRadius: 28,
          offset: const Offset(0, 14),
          spreadRadius: -6,
        ),
      ],
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: ring,
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        scheme.surfaceContainerHigh,
                        scheme.surfaceContainerLow,
                      ]
                    : [
                        Colors.white,
                        scheme.surfaceContainerLowest,
                      ],
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.checkroom_rounded,
              size: 42,
              color: scheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Xush kelibsiz',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: scheme.onSurface,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Davom etish uchun akkauntingizga kiring',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
