import 'package:flutter/services.dart';

/// Uzbekistan mobile display: `+998 XX XXX XX XX` (9 raqam milliy qism).
///
/// Submit uchun [normalizeForSubmit] — `998` + 9 raqam (masalan `998901112233`).
final class UzbekPhoneInputFormatter extends TextInputFormatter {
  static const String visiblePrefix = '+998 ';

  static bool _isDigit(String ch) =>
      ch.length == 1 && ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39;

  /// Faqat raqamlar; map kaliti bilan mos (`998xxxxxxxxx`).
  static String normalizeForSubmit(String raw) {
    var d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('998')) {
      if (d.length > 12) d = d.substring(0, 12);
      return d;
    }
    if (d.length > 9) d = d.substring(0, 9);
    return '998$d';
  }

  /// Demo / `MockAccounts` kalitlari (`998...`) uchun ko'rinish.
  static String formatFromStoreKey(String twelveOrMoreDigits) {
    var d = twelveOrMoreDigits.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('998')) d = d.substring(3);
    if (d.length > 9) d = d.substring(0, 9);
    return _formatNational(d);
  }

  static String _formatNational(String nineDigits) {
    final d = nineDigits.length > 9 ? nineDigits.substring(0, 9) : nineDigits;
    final buf = StringBuffer(visiblePrefix);
    for (var i = 0; i < d.length; i++) {
      if (i == 2 || i == 5 || i == 7) buf.write(' ');
      buf.write(d[i]);
    }
    return buf.toString();
  }

  static String _extractNationalDigits(String input) {
    var all = input.replaceAll(RegExp(r'\D'), '');
    if (all.startsWith('998')) all = all.substring(3);
    if (all.length > 9) all = all.substring(0, 9);
    return all;
  }

  static int _digitsBeforeCursor(String text, int cursor) {
    final end = cursor.clamp(0, text.length);
    var n = 0;
    for (var i = 0; i < end; i++) {
      if (_isDigit(text[i])) n++;
    }
    return n;
  }

  /// Milliy qismidagi raqamlar sonigacha cursor (`nationalDigitsShown` ∈ [0, 9]).
  static int caretOffset(String formatted, int nationalDigitsShown) {
    final target = nationalDigitsShown.clamp(0, 9);
    if (target == 0) return visiblePrefix.length;
    var seen = 0;
    for (var i = visiblePrefix.length; i < formatted.length; i++) {
      if (_isDigit(formatted[i])) {
        seen++;
        if (seen == target) return i + 1;
      }
    }
    return formatted.length;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final national = _extractNationalDigits(newValue.text);
    final formatted = _formatNational(national);

    final caretRaw = newValue.selection.baseOffset;
    final digitsBefore = _digitsBeforeCursor(newValue.text, caretRaw);
    final nationalBefore = (digitsBefore - 3).clamp(0, national.length);

    final offset = caretOffset(formatted, nationalBefore);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }
}
