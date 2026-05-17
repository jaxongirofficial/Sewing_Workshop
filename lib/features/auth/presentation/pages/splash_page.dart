import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_constants.dart';
import '../../../../config/routes/route_paths.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../shared/widgets/brand/brand_backdrop.dart';
import '../../../../shared/widgets/brand/brand_logo.dart';
import '../providers/auth_notifier.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Timer? _redirect;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _redirect = Timer(const Duration(milliseconds: 1300), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final auth = ref.read(authNotifierProvider);
    if (auth.isAuthenticated && auth.user != null) {
      context.go(dashboardLocationForRole(auth.user!.role));
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _redirect?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final overlay = isDark
        ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
        : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const BrandBackdrop(),
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _ctrl,
                    curve: Curves.easeOut,
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.06),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _ctrl,
                      curve: Curves.easeOutCubic,
                    )),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BrandLogo(size: 104, iconSize: 48),
                        const SizedBox(height: 28),
                        Text(
                          AppConstants.appName,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tikuv ustaxonasi — jamoa va ish jarayoni',
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 36),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            color: scheme.primary,
                          ),
                        ),
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
