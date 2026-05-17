import 'package:flutter/material.dart';

/// Semantic and brand tokens. Prefer referencing these over raw [Color] literals.
abstract final class AppColors {
  static const Color seed = Color(0xFF2254D9);
  static const Color ink = Color(0xFF0F172A);
  static const Color slate = Color(0xFF475467);
  static const Color cloud = Color(0xFFF3F6FC);
  static const Color panel = Color(0xFFFFFFFF);
  static const Color panelMuted = Color(0xFFF8FAFD);
  static const Color stroke = Color(0xFFD9E2F1);
  static const Color shadow = Color(0xFF0B1324);

  /// Role accents for subtle differentiation.
  static const Color ownerAccent = Color(0xFF7C3AED);
  static const Color managerAccent = Color(0xFF0F8B8D);
  static const Color workerAccent = Color(0xFF0F9F6E);

  static const Color success = Color(0xFF149A5A);
  static const Color warning = Color(0xFFC97A10);
  static const Color danger = Color(0xFFD92D20);

  static const Color dashboardBackdrop = Color(0xFFF4F7FC);
  static const Color dashboardBackdropDark = Color(0xFF09111F);

  /// Premium auth surfaces.
  static const Color loginBackdropTop = Color(0xFFF7F8FC);
  static const Color loginBackdropBottom = Color(0xFFE8EEFF);
  static const Color loginGlow = Color(0xFFDCE7FF);
  static const Color loginGlowSecondary = Color(0xFFE7F4F1);
}
