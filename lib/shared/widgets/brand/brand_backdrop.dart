import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

/// Ilovaning yagona ambient foni — barcha asosiy ekranlar tagiga qo‘yiladi.
///
/// Yumshoq gradient + sokin orblar bilan kompozitsiya yaratadi. Faqat brend
/// rangidan foydalanadi, shu sababli butun ilova bir xil “oilada” bo‘ladi.
class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({super.key, this.intensity = 1.0});

  /// 0..1 — orblar va yorqinlik darajasi. Login uchun 1.0, dashboard uchun 0.85.
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: Stack(
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
                        Color.lerp(AppColors.dashboardBackdropDark,
                            scheme.primary, 0.10)!,
                        const Color(0xFF080F1C),
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
            right: -90,
            top: -70,
            child: _Orb(
              size: 280,
              color: scheme.primary
                  .withValues(alpha: (isDark ? 0.22 : 0.30) * intensity),
            ),
          ),
          Positioned(
            left: -110,
            bottom: 60,
            child: _Orb(
              size: 320,
              color: scheme.primary
                  .withValues(alpha: (isDark ? 0.16 : 0.22) * intensity),
            ),
          ),
          Positioned(
            left: 40,
            top: 160,
            child: _Orb(
              size: 150,
              color: AppColors.loginGlowSoft
                  .withValues(alpha: (isDark ? 0.10 : 0.45) * intensity),
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0.2, 1],
        ),
      ),
    );
  }
}
