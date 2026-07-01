import 'package:flutter/services.dart';

/// 전화번호 포맷터
class PhoneNumberFormatter extends TextInputFormatter {
  static const kPhoneNumberPrefix = '010-';
  static const int kMaxPhoneNumberLength = 11; // 숫자만 11자리로 제한

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String formattedText = _getFormattedPhoneNumber(newValue.text);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  // 전화번호의 길이에 따라 형식을 지정하는 메서드
  String _getFormattedPhoneNumber(String value) {
    value = _cleanPhoneNumber(value);

    // 최대 11자리로 제한
    if (value.length > kMaxPhoneNumberLength) {
      value = value.substring(0, kMaxPhoneNumberLength);
    }

    if (value.length == 1) {
      // 값이 없을 때 010-최초값 포멧
      value = kPhoneNumberPrefix + value.substring(0, value.length);
    } else if (value.length < 4) {
      // 010- 을 지우지 못하도록 010- 유지
      value = kPhoneNumberPrefix;
    } else if (value.length >= 8 && value.length < 12) {
      // 010-xxxx-xxxx 포멧
      value =
          '$kPhoneNumberPrefix${value.substring(3, 7)}-${value.substring(7, value.length)}';
    } else {
      // 010-xxxx 포멧
      value = kPhoneNumberPrefix + value.substring(3, value.length);
    }

    return value;
  }

  // 입력에서 숫자가 아닌 문자를 제거하는 메서드
  String _cleanPhoneNumber(String value) {
    return value.replaceAll(RegExp(r'[-\s]'), '');
  }
}
