import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owner FAB ning ekrandagi joyi. `null` — sukut bo'yicha o'ng pastdagi joy.
///
/// Foydalanuvchi uzoq bosib turib FAB ni boshqa joyga olib o'tganida
/// shu provider yangilanadi va keyingi sahifalarda ham saqlanib qoladi.
final fabPositionProvider = StateProvider<Offset?>((ref) => null);
