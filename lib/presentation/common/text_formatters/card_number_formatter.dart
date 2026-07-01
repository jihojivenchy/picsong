import 'package:flutter/services.dart';

/// 카드번호 입력 포맷터 — 숫자만 허용하고 4자리마다 공백 삽입
class CardNumberFormatter extends TextInputFormatter {
  /// 카드번호 최대 자릿수 (숫자만, 공백 제외)
  static const int _maxDigits = 19;

  /// 그룹 단위 (4자리)
  static const int _groupSize = 4;

  const CardNumberFormatter();

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
    final String formatted = _insertSpaces(trimmed);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// 4자리마다 공백을 삽입한 문자열 반환
  String _insertSpaces(String digits) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % _groupSize == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
