import 'package:flutter/services.dart';

class IdentificationNumberFormatter extends TextInputFormatter {
  // 텍스트 편집 업데이트를 처리하기 위해 formatEditUpdate 메서드를 재정의
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 백스페이스 동작 감지 (텍스트가 줄어든 경우)
    bool isBackspace = newValue.text.length < oldValue.text.length;
    
    // 현재 입력된 숫자만 추출 (이전 값에서)
    String oldDigitsOnly = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 7자리 입력 완료한 상태에서 백스페이스를 누른 경우
    if (isBackspace && oldDigitsOnly.length == 7 && oldValue.text.contains('●')) {
      // 7번째 자리(성별코드)를 지우고 6자리 상태로 돌아감
      String frontSix = oldDigitsOnly.substring(0, 6);
      return TextEditingValue(
        text: frontSix,
        selection: TextSelection.collapsed(offset: frontSix.length),
      );
    }

    // 포맷된 텍스트 반환
    String formattedText = _getFormattedIdentificationNumber(newValue.text);

    // 업데이트된 선택과 함께 포맷된 텍스트를 반환
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  // 주민등록번호의 길이에 따라 형식을 지정하는 메서드
  String _getFormattedIdentificationNumber(String value) {
    // 숫자만 추출
    String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    // 최대 7자리까지만 허용 (생년월일 6자리 + 성별코드 1자리)
    if (digitsOnly.length > 7) {
      digitsOnly = digitsOnly.substring(0, 7);
    }

    /// 1. 유저가 숫자를 입력하면, 000000-0●●●●●● 포멧으로 입력될 수 있도록 처리,
    /// 2. 7자리 숫자만 입력할 수 있도록 제한 (총 14자리 숫자만 입력할 수 있도록 제한)
    /// 3. 6자리를 입력하면 -를 표기

    if (digitsOnly.isEmpty) {
      return '';
    } else if (digitsOnly.length <= 6) {
      // 앞 6자리 생년월일 입력 중
      return digitsOnly;
    } else if (digitsOnly.length == 7) {
      // 7번째 자리(성별코드) 입력 완료 - 나머지 6자리는 ●로 고정 표시
      String frontSix = digitsOnly.substring(0, 6);
      String seventhDigit = digitsOnly.substring(6, 7);
      return '$frontSix-$seventhDigit●●●●●●';
    }

    return digitsOnly;
  }
}
