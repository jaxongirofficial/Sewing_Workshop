import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Foydalanuvchi tanlagan tema rejimi (yorug‘ / qorong‘u / tizim).
///
/// Hozircha xotirada (process davomida) saqlanadi — keyinroq `SharedPreferences`
/// orqali qattiq saqlash qo‘shilishi mumkin.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setMode(ThemeMode mode) => state = mode;
}

extension ThemeModeX on ThemeMode {
  String get uzLabel => switch (this) {
        ThemeMode.light => 'Yorug‘',
        ThemeMode.dark => 'Qorong‘u',
        ThemeMode.system => 'Tizim',
      };

  IconData get icon => switch (this) {
        ThemeMode.light => Icons.light_mode_rounded,
        ThemeMode.dark => Icons.dark_mode_rounded,
        ThemeMode.system => Icons.brightness_auto_rounded,
      };
}
