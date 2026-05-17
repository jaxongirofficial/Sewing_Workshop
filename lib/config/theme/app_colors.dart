import 'package:flutter/material.dart';

/// App-wide design tokens — yagona brend rangi (`brand`) atrofiga qurilgan.
abstract final class AppColors {
  // — Brand —
  static const Color brand = Color(0xFF3B5BFE);
  static const Color brandDeep = Color(0xFF2440D4);
  static const Color brandSoft = Color(0xFFE6ECFF);
  static const Color brandTint = Color(0xFFF1F4FF);

  // — Neutrals (light) —
  static const Color ink = Color(0xFF0F172A);
  static const Color inkSoft = Color(0xFF1E293B);
  static const Color slate = Color(0xFF475467);
  static const Color slateSoft = Color(0xFF64748B);
  static const Color cloud = Color(0xFFF6F8FC);
  static const Color panel = Color(0xFFFFFFFF);
  static const Color panelMuted = Color(0xFFF8FAFD);
  static const Color stroke = Color(0xFFE2E8F5);
  static const Color strokeSoft = Color(0xFFEEF2F8);
  static const Color shadow = Color(0xFF0B1324);

  // — Status —
  static const Color success = Color(0xFF12B981);
  static const Color warning = Color(0xFFE08A14);
  static const Color danger = Color(0xFFE0413A);

  // — Light backgrounds —
  static const Color dashboardBackdrop = Color(0xFFF4F7FC);
  static const Color loginBackdropTop = Color(0xFFF6F8FF);
  static const Color loginBackdropBottom = Color(0xFFE3EAFF);
  static const Color loginGlow = Color(0xFFD8E2FF);
  static const Color loginGlowSoft = Color(0xFFEFEAFF);

  // — Dark palette (elevation-aware) —
  /// Eng chuqur fon (scaffold).
  static const Color darkBg = Color(0xFF060B17);

  /// Backdrop ostidagi yumshoq fon.
  static const Color darkBgSoft = Color(0xFF0A1224);

  /// Asosiy kartochka rangi (ko‘tarilgan sirt).
  static const Color darkCard = Color(0xFF17223C);

  /// Yuqori elevatsiya — modal, dropdown, input.
  static const Color darkCardHigh = Color(0xFF1E2A48);

  /// Ko‘rinarli chegara.
  static const Color darkBorder = Color(0xFF2A3756);

  /// Yumshoq, ozgina ko‘rinadigan chegara.
  static const Color darkBorderSoft = Color(0xFF1B2740);

  // — Legacy aliaslar (eski referenslar uchun) —
  static const Color dashboardBackdropDark = darkBg;
  static const Color darkSurface = darkCard;
  static const Color darkSurfaceHigh = darkCardHigh;
}
