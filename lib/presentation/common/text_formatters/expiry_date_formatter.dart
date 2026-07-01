import 'package:flutter/services.dart';

/// 만료일(MM/YY) 입력 포맷터 — 숫자만 허용하고 MM 뒤에 / 삽입
class ExpiryDateFormatter extends TextInputFormatter {
  /// 최대 4자리 (MMYY)
  static const int _maxDigits = 4;

  const ExpiryDateFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digitsOnly =
        newValue.text.replaceAll(RegExp(r'\D'), '');
    final String trimmed = digitsOnly.length > _maxDigits
        ? digitsOnly.substring(0, _maxDigits)
        : digitsOnly;
    final String formatted = _insertSlash(trimmed);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// MM 뒤에 / 삽입
  String _insertSlash(String digits) {
    if (digits.length <= 2) {
      return digits;
    }
    return '${digits.substring(0, 2)}/${digits.substring(2)}';
  }
}
