import 'package:intl/intl.dart';

extension IntExtension on int {
  /// 포인트 콤마 형식
  String get withComma {
    try {
      final NumberFormat formatter = NumberFormat('#,###');
      return formatter.format(this);
    } catch (e) {
      return toString();
    }
  }

  /// 숫자를 2자리 문자열로 변환 (예: 1 -> "01", 12 -> "12")
  String get toTwoDigit {
    return toString().padLeft(2, '0');
  }

  /// 숫자를 지정된 자릿수 문자열로 변환
  ///
  /// [width] 원하는 자릿수
  /// [padChar] 패딩에 사용할 문자 (기본값: '0')
  String toPaddedString(int width, [String padChar = '0']) {
    return toString().padLeft(width, padChar);
  }

  /// 숫자를 3자리 문자열로 변환 (예: 1 -> "001", 123 -> "123")
  String get toThreeDigitString {
    return toString().padLeft(3, '0');
  }

  /// 숫자를 4자리 문자열로 변환 (예: 1 -> "0001", 1234 -> "1234")
  String get toFourDigitString {
    return toString().padLeft(4, '0');
  }

  /// 두 자리 숫자 형식 변환
  String get twoDigits => toString().padLeft(2, '0');
}
