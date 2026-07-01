import 'package:intl/intl.dart';

const List<String> _koreanWeekdays = [
  '월요일',
  '화요일',
  '수요일',
  '목요일',
  '금요일',
  '토요일',
  '일요일',
];

extension DateTimeExtension on DateTime {
  /// DateTime을 원하는 포맷의 문자열로 변환합니다.
  ///
  /// [format] - 날짜 포맷 (기본값: 'yyyy.MM')
  ///
  String toStringFormat([String format = 'yyyy.MM']) {
    return DateFormat(format).format(this);
  }

  /// DateTime을 년 문자열로 변환합니다.
  ///
  /// 예시: `DateTime.now().toYear()` -> "2024"
  String toYear() {
    return DateFormat('yyyy').format(this);
  }

  /// DateTime을 월 문자열로 변환합니다.
  ///
  /// 예시: `DateTime.now().toMonth()` -> "01"
  String toMonth() {
    return DateFormat('MM').format(this);
  }

  /// DateTime을 "MM월 dd일 요일" 형식으로 변환합니다.
  ///
  /// 예시: `DateTime(2025, 3, 1).toKoreanMonthDayWeekday()` -> "03월 01일 일요일"
  String toKoreanMonthDayWeekday() {
    final formattedDate = DateFormat('MM월 dd일').format(this);
    final weekdayLabel = _koreanWeekdays[weekday - 1];
    return '$formattedDate $weekdayLabel';
  }

  /// DateTime을 "오전/오후 H시 m분" 형식으로 변환합니다.
  ///
  /// 예시: `DateTime(2025, 3, 1, 9, 41).toKoreanTimeWithMeridiem()` -> "오전 9시 41분"
  String toKoreanTimeWithMeridiem() {
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$period $displayHour시 $minute분';
  }
}
