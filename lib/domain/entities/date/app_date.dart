/// 날짜 엔티티
class AppDate {
  final String year;
  final String month;
  final String day;

  const AppDate({
    required this.year,
    required this.month,
    required this.day,
  });

  /// 문자열 형식의 생년월일 → AppDate 엔티티로 변환
  factory AppDate.fromString(String birthday) {
    final parts = birthday.split('-');

    return AppDate(
      year: parts.isNotEmpty ? parts[0] : '',
      month: parts.length > 1 ? parts[1] : '',
      day: parts.length > 2 ? parts[2] : '',
    );
  }

  /// DateTime 객체 → AppDate 엔티티로 변환
  factory AppDate.fromDateTime(DateTime dateTime) {
    return AppDate(
      year: dateTime.year.toString(),
      month: dateTime.month.toString().padLeft(2, '0'),
      day: dateTime.day.toString().padLeft(2, '0'),
    );
  }

  /// 오늘 날짜로 초기화된 AppDate 객체를 반환
  static AppDate get initialState {
    return AppDate.fromDateTime(DateTime.now());
  }

  bool get isValid => year.isNotEmpty && month.isNotEmpty && day.isNotEmpty;

  /// AppDate -> 쿼리 문자열 형식 '2023-05-05'
  String toQueryString() {
    if (year.isEmpty || month.isEmpty || day.isEmpty) {
      return '';
    }

    return '$year-${month.padLeft(2, '0')}-${day.padLeft(2, '0')}';
  }

  /// 현재 날짜 기준 만 나이 계산
  int calculateAge() {
    if (!isValid) return 0;
    final now = DateTime.now();
    int age = now.year - int.parse(year);
    if (now.month < int.parse(month) ||
        (now.month == int.parse(month) && now.day < int.parse(day))) {
      age--;
    }
    return age;
  }

  /// AppDate -> 표시용 문자열 형식 '2023-05-05'
  String toDisplayString() {
    if (year.isEmpty || month.isEmpty || day.isEmpty) {
      return '';
    }

    return '$year-${month.padLeft(2, '0')}-${day.padLeft(2, '0')}';
  }
}
