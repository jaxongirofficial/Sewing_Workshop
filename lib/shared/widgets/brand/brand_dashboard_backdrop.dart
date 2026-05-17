import 'package:flutter/material.dart';

/// Dashboard uchun toza, dam beruvchi fon.
///
/// Yumshoq vertikal gradient + AppBar atrofida bitta yengil brend halqa.
/// Kartochkalar yaqqol ko‘rinishi uchun ortiqcha narsa qo‘shilmagan.
class BrandDashboardBackdrop extends StatelessWidget {
  const BrandDashboardBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final top = isDark ? const Color(0xFF0C1626) : const Color(0xFFF1F4FB);
    final bottom = isDark ? const Color(0xFF070D1C) : const Color(0xFFE6ECF6);

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [top, bottom],
              ),
            ),
          ),
          Positioned(
            top: -180,
            right: -140,
            child: Container(
              width: 460,
              height: 460,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    scheme.primary.withValues(alpha: isDark ? 0.20 : 0.18),
                    scheme.primary.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
