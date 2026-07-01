import 'package:intl/intl.dart';
import 'package:picsong/utils/extensions/int_extension.dart';
import 'package:picsong/utils/services/app_logger.dart';

const List<String> _koreanWeekdays = [
  '월요일',
  '화요일',
  '수요일',
  '목요일',
  '금요일',
  '토요일',
  '일요일',
];

const List<String> _koreanShortWeekdays = [
  '월',
  '화',
  '수',
  '목',
  '금',
  '토',
  '일',
];

extension StringExtension on String {
  /// 포인트 콤마 형식
  String get withComma {
    try {
      final int pointValue = int.parse(this);
      final NumberFormat formatter = NumberFormat('#,###');
      return formatter.format(pointValue);
    } catch (e) {
      return this;
    }
  }

  /// 휴대폰 번호에 하이픈을 추가
  /// 예: "01012345678" -> "010-1234-5678"
  String get formattedPhoneNumber {
    if (length != 11) return this;

    return '${substring(0, 3)}-${substring(3, 7)}-${substring(7, 11)}';
  }

  ///
  /// 문자열을 yyyy.MM.dd 형식의 문자열로 변환
  ///
  String toYYYYMMDD() {
    try {
      final DateTime date = DateTime.parse(this);
      return DateFormat('yyyy.MM.dd').format(date);
    } catch (e) {
      AppLogger.log('날짜 형식이 잘못되었습니다. 올바른 형식: YYYY-MM-DD');
      return '';
    }
  }

  /// 문자열을 yyyy.MM.dd HH:mm 형식으로 변환
  String toYYYYMMDDHHMM() {
    final date = DateTime.parse(this);
    return DateFormat('yyyy.MM.dd HH:mm').format(date);
  }

  /// 문자열을 원하는 포맷의 문자열로 변환합니다.
  ///
  /// [format] - 날짜 포맷 (기본값: 'yyyy년 MM월 dd일')
  ///
  String toFormat([String format = 'yyyy년 MM월 dd일']) {
    try {
      final date = DateTime.parse(this);
      return DateFormat(format).format(date);
    } catch (e) {
      return '';
    }
  }

  ///
  /// 마지막 기록 날짜 포맷팅
  ///
  String toLastRecordDateFormat() {
    try {
      final date = DateTime.parse(this);
      final now = DateTime.now();
      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      final hour = date.hour;
      final period = hour < 12 ? '오전' : '오후';
      final displayHour = hour <= 12 ? hour : hour - 12;

      if (isToday) {
        return '오늘 $period $displayHour시 기록';
      } else {
        return '${date.month}월 ${date.day}일 $period $displayHour시 기록';
      }
    } catch (e) {
      return this;
    }
  }

  ///
  /// DateTime을 요일 문자열로 변환
  ///
  String toWeekdayFormat() {
    try {
      final weekday = DateTime.parse(this).weekday;
      return _koreanWeekdays[weekday - 1];
    } catch (e) {
      return '요일 오류';
    }
  }

  /// 문자열을 yyyy년 MM월 dd일 요일 형식으로 변환
  String toKoreanFullDateWithWeekday() {
    try {
      final date = DateFormat('yyyy-MM-dd').parseStrict(this);
      final formattedDate = DateFormat('yyyy년 MM월 dd일').format(date);
      final weekday = _koreanWeekdays[date.weekday - 1];
      return '$formattedDate $weekday';
    } catch (e) {
      return '날짜 형식 오류';
    }
  }

  /// 문자열을 yyyy.MM.dd (요일) 형식으로 변환
  String toDottedDateWithWeekday() {
    try {
      final DateTime date = DateFormat('yyyy-MM-dd').parseStrict(this);
      final String formattedDate = DateFormat('yyyy.MM.dd').format(date);
      final String weekday = _koreanShortWeekdays[date.weekday - 1];
      return '$formattedDate ($weekday)';
    } catch (e) {
      return '날짜 형식 오류';
    }
  }

  /// 문자열을 MM/dd 요일 오전/오후 h:mm 형식으로 변환
  /// 예: 2025-10-20T14:30:00 -> 10/20 토요일 오후 2:30
  String toMonthDayKoreanWeekdayWithMeridiem() {
    try {
      final dateTime = DateTime.parse(this);
      final monthDay = DateFormat('MM/dd').format(dateTime);
      final weekday = _koreanWeekdays[dateTime.weekday - 1];

      final isPm = dateTime.hour >= 12;
      final hour12 = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final meridiem = isPm ? '오후' : '오전';

      return '$monthDay $weekday $meridiem $hour12:$minute';
    } catch (e) {
      return '날짜 형식 오류';
    }
  }

  ///
  /// 오늘 날짜일 경우: "오전/오후 hh:mm" 형식으로 변환
  /// 오늘 날짜가 아닐 경우: "yyyy.MM.dd" 형식으로 변환
  ///
  String toChatTimeFormat() {
    try {
      // UTC 시간으로 파싱
      final utcDateTime = DateTime.parse('${this}Z');


      // 한국 시간으로 변환
      final koreanTime = utcDateTime.add(const Duration(hours: 9));
      final now = DateTime.now();

      // 오늘 날짜인지 확인 (년, 월, 일만 비교)
      final isToday = koreanTime.year == now.year &&
          koreanTime.month == now.month &&
          koreanTime.day == now.day;

      if (isToday) {
        // 오늘인 경우 => "오전/오후 hh:mm" 형식
        final hour = koreanTime.hour;
        final minute = koreanTime.minute;

        final period = hour < 12 ? '오전' : '오후';
        final displayHour = hour % 12 == 0 ? 12 : hour % 12;

        return '$period ${displayHour.toTwoDigit}:${minute.toTwoDigit}';
      } else {
        // 오늘 아닌 경우 => "yyyy.MM.dd" 형식
        return DateFormat('yyyy.MM.dd').format(koreanTime);
      }
    } catch (e) {
      return '시간 오류';
    }
  }

  ///
  /// UTC 시각 문자열을 한국 시간 기준 상대 시간 텍스트("X분 전")로 변환
  ///
  String toRelativeTimeText() {
    if (isEmpty) return '';
    try {
      // UTC 시간으로 파싱 (Z 미포함 입력 대응)
      final DateTime utcDateTime = DateTime.parse(endsWith('Z') ? this : '${this}Z');

      // 한국 시간으로 변환
      final DateTime koreanTime = utcDateTime.add(const Duration(hours: 9));

      // 현재 시각과의 차이 계산
      final Duration diff = DateTime.now().difference(koreanTime);

      // 0분 이하이면 "방금 전"
      if (diff.inMinutes <= 0) return '방금 전';

      // 1~59분
      if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';

      // 1~23시간
      if (diff.inHours < 24) return '${diff.inHours}시간 전';

      // 1~6일
      if (diff.inDays < 7) return '${diff.inDays}일 전';

      // 1~4주 (30일 미만인 경우 주 단위)
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주 전';

      // 1~11달 (365일 미만인 경우 달 단위)
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}달 전';

      // 1년 이상
      return '${(diff.inDays / 365).floor()}년 전';
    } catch (_) {
      return '';
    }
  }

  ///
  /// 게시물 시간 포맷
  ///
  String toFeedTimeFormat() {
    try {
      // UTC 시간으로 파싱
      final utcDateTime = DateTime.parse(this);

      // 한국 시간으로 변환
      final DateTime koreanTime = utcDateTime.add(const Duration(hours: 9));

      // 현재 시각과의 차이 계산
      final DateTime now = DateTime.now();
      final Duration diff = now.difference(koreanTime);

      AppLogger.log('시간 비교 now: $now, koreanTime: $koreanTime, diff: $diff');

      // 0분 미만이면 "방금"
      if (diff.inMinutes <= 0) return '방금';

      // 1~59분
      if (diff.inMinutes < 60) return '${diff.inMinutes}분';

      // 1~23시간
      if (diff.inHours < 24) return '${diff.inHours}시간';

      // 1~6일
      if (diff.inDays < 7) return '${diff.inDays}일';

      // 1~4주 (30일 미만인 경우 주 단위로 표시)
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주';

      // 1~11달 (365일 미만인 경우 달 단위로 표시)
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}달';

      // 1년 이상
      return '${(diff.inDays / 365).floor()}년';
    } catch (e) {
      // 파싱 실패
      return toYYYYMMDDHHMM();
    }
  }
}
