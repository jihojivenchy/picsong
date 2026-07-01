import 'package:picsong/domain/entities/date/day.dart';

typedef CalendarDayMap = Map<DateTime, List<Day>>;

///
/// 캘린더 서비스
/// 캘린더 시작 날짜와 종료 날짜를 기반으로 Day 리스트를 반환
///
class CalendarService {
  
  /// 캘린더 시작 요일
  final StartingDayOfWeek _startingDayOfWeek = StartingDayOfWeek.sunday;

  ///
  /// 특정 날짜에 대한 DayList 계산
  ///
  List<Day> calculateDayList(DateTime focusedDay) {
    // 해당 월의 날짜 범위를 기반으로 Day 리스트를 계산
    final range = _daysInMonth(focusedDay);
    final days = _calculateDays(range.start, range.end, focusedDay);
    return days;
  }

  ///
  /// StartingDayOfWeek 기준으로 요일 순서를 반환하는 메서드
  /// 순서: [일, 월, 화, 수, 목, 금, 토] (Sunday-first 기준)
  ///
  List<String> calculateWeekList(List<String> weekDays) {
    assert(weekDays.length == 7, 'weekDays must contain exactly 7 elements');

    // enum index: monday(0) ~ sunday(6)
    final startIndex = (_startingDayOfWeek.index + 1) % 7;

    // 요일 배열을 순환 정렬
    return List.generate(7, (i) => weekDays[(startIndex + i) % 7]);
  }

  ///
  /// DayMap 계산
  ///
  CalendarDayMap calculateDayMap() {
    final CalendarDayMap calendarMap = {};
    // DateTime current = DateTime(_startDate.year, _startDate.month);
    // final DateTime end = DateTime(_endDate.year, _endDate.month + 1);

    // // 캘린더 시작 날짜부터 종료 날짜까지 반복
    // while (current.isBefore(end)) {
    //   // 현재 월에 해당하는 포커싱 날짜
    //   final focusedDay = DateTime(current.year, current.month);

    //   final range = _daysInMonth(focusedDay);
    //   final days = _calculateDays(range.start, range.end, focusedDay);

    //   // 해당 월을 key로 Day 리스트 저장
    //   calendarMap[focusedDay] = days;

    //   // 다음 월로 이동
    //   current = DateTime(current.year, current.month + 1);
    // }

    return calendarMap;
  }

  ///
  /// 해당 월의 날짜 범위를 기반으로 Day 리스트를 계산하는 메서드
  ///
  List<Day> _calculateDays(DateTime first, DateTime last, DateTime focusedDay) {
    final dayCount = last.difference(first).inDays + 1;
    final now = DateTime.now();

    // 날짜 범위 내의 날짜 개수만큼 반복하며 Day 객체 생성
    return List.generate(dayCount, (index) {
      final day = DateTime.utc(first.year, first.month, first.day + index);

      final isOutside = day.month != focusedDay.month;

      var state = DayCellState.basic;

      // 일요일 또는 토요일 여부 확인
      if (_isSunday(day)) {
        state = DayCellState.sunday;
      } else if (_isSaturday(day)) {
        state = DayCellState.saturday;
      }

      // 오늘 날짜 여부 확인
      final isToday =
          now.year == day.year && now.month == day.month && now.day == day.day;

      if (isToday) {
        state = DayCellState.today;
      }

      return Day(date: day, isOutside: isOutside, state: state);
    });
  }

  ///
  /// 특정 월을 기준으로 캘린더에 표시할 날짜 범위를 계산하는 함수
  /// 해당 월의 모든 날짜 + 앞뒤 빈 공간을 채우는 이전/다음 월의 날짜들을 포함
  ///
  ({DateTime start, DateTime end}) _daysInMonth(DateTime focusedDay) {
    // 1. 해당 월의 첫 번째 날 (예: 2025년 3월 1일)
    final first = _firstDayOfMonth(focusedDay);

    // 2. 첫 번째 날 이전에 표시할 날짜의 개수 계산
    // 예: 3월 1일이 토요일이면, 일~금요일(6개)의 이전 월 날짜가 필요
    final daysBefore = _getBeforeDays(first);

    // 3. 실제 캘린더에서 표시할 첫 번째 날짜 계산
    // 예: 3월 1일이 토요일이면 2월 23일(일요일)부터 시작
    final firstToDisplay = first.subtract(Duration(days: daysBefore));

    // 4. 해당 월의 마지막 날 계산 (예: 3월 31일)
    final last = _lastDayOfMonth(focusedDay);

    // 5. 마지막 날 이후에 표시할 날짜의 개수 계산
    // 예: 3월 31일이 월요일이면, 화~토요일(5개)의 다음 월 날짜가 필요
    final daysAfter = _getAfterDays(last);

    // 6. 실제 캘린더에서 표시할 마지막 날짜 계산
    // 예: 3월 31일이 월요일이면 4월 5일(토요일)까지 표시
    final lastToDisplay = last.add(Duration(days: daysAfter));

    // 7. 계산된 시작일부터 종료일까지의 날짜 범위 반환
    return (start: firstToDisplay, end: lastToDisplay);
  }

  ///
  /// 월의 첫 번째 날을 계산하는 메서드
  ///
  DateTime _firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month);
  }

  ///
  /// 월의 첫 번째 날 이전에 표시할 날짜의 개수 계산
  ///
  int _getBeforeDays(DateTime firstDay) {
    // 월의 첫 번째 날의 요일 번호와 시작 요일 번호의 차이를 계산하여 이전 월의 날짜 개수 반환
    return (firstDay.weekday + 7 - getWeekdayNumber(_startingDayOfWeek)) % 7;
  }

  ///
  /// 요일 번호 반환 (일요일: 1, 월요일: 2, 화요일: 3, 수요일: 4, 목요일: 5, 금요일: 6, 토요일: 7)
  ///
  int getWeekdayNumber(StartingDayOfWeek weekday) {
    return StartingDayOfWeek.values.indexOf(weekday) + 1;
  }

  ///
  /// 월의 마지막 날을 계산하는 메서드
  ///
  DateTime _lastDayOfMonth(DateTime month) {
    // 월이 12월이면 다음 해의 1월
    // 월이 12월이 아니면 다음 달의 1일
    final date = month.month < 12
        ? DateTime.utc(month.year, month.month + 1)
        : DateTime.utc(month.year + 1);

    // -1 해주면 마지막 날이 계산됨
    return date.subtract(const Duration(days: 1));
  }

  ///
  /// 월의 마지막 날 이후에 보여줘야 할 '다음 달 날짜 수'를 계산
  ///
  int _getAfterDays(DateTime lastDay) {
    // 달력의 시작 요일(예: 일요일, 월요일 등)에 따라 요일 번호를 반전시킴
    // 예: 시작 요일이 일요일이면 weekday 번호가 1이 되어야 하므로 -> 8 - 1 = 7
    // 예: 시작 요일이 월요일이면 -> 8 - 2 = 6
    final invertedStartingWeekday = 8 - getWeekdayNumber(_startingDayOfWeek);

    // (마지막 날짜의 요일 + 시작 요일 기준 보정값)을 7로 나눈 나머지를 구함
    // 이 결과는 달력의 주 마지막 열까지 얼마나 채워졌는지를 의미
    final daysAfter = 7 - ((lastDay.weekday + invertedStartingWeekday) % 7);

    // 만약 7일이 모두 채워졌다면, 다음 달 날짜는 필요 없음
    if (daysAfter == 7) {
      return 0;
    }

    // 채워야 할 다음 달 날짜 수 반환
    return daysAfter;
  }

  ///
  /// 일요일 여부 확인
  ///
  bool _isSunday(DateTime day) {
    return day.weekday == DateTime.sunday;
  }

  ///
  /// 토요일 여부 확인
  ///
  bool _isSaturday(DateTime day) {
    return day.weekday == DateTime.saturday;
  }
}
