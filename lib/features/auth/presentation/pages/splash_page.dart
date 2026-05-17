import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_constants.dart';
import '../../../../config/routes/route_paths.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../shared/widgets/atoms/app_badge.dart';
import '../../../../shared/widgets/atoms/app_card.dart';
import '../../../../shared/widgets/layout/auth_backdrop.dart';
import '../providers/auth_notifier.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  Timer? _splashHold;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleSplashExit());
  }

  void _scheduleSplashExit() {
    _splashHold?.cancel();
    _splashHold = Timer(AppConstants.splashMinDuration, () {
      if (!mounted) return;

      final auth = ref.read(authNotifierProvider);
      if (auth.isAuthenticated) return;

      if (!context.mounted) return;
      context.go(AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _splashHold?.cancel();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AuthBackdrop(
        child: Center(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AppCard(
                hoverable: false,
                backgroundColor: scheme.surface.withValues(alpha: 0.82),
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppBadge(
                      label: 'Operations platform',
                      icon: Icons.grid_view_rounded,
                      tone: AppBadgeTone.primary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.auto_awesome_mosaic_rounded,
                        size: 34,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      AppConstants.appName,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Operations, production, and teams in one view.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
