import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/app_fonts.dart';

/// 픽송 타이포그래피 스케일 (Pretendard)
/// size / line-height / weight / tracking 을 디자인 토큰에서 1:1 포팅.
abstract final class AppTypography {
  /// 점수·정답 공개 등 가장 큰 강조 (34/42, Bold)
  static const TextStyle display = TextStyle(
    fontFamily: AppFonts.pretendard,
    fontSize: 34,
    height: 42 / 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 34 * -0.02,
  );

  /// 화면 대표 제목 (28/36, Bold)
  static const TextStyle title1 = TextStyle(
    fontFamily: AppFonts.pretendard,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 28 * -0.018,
  );

  /// 섹션 제목 (22/30, SemiBold)
  static const TextStyle title2 = TextStyle(
    fontFamily: AppFonts.pretendard,
    fontSize: 22,
    height: 30 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 22 * -0.014,
  );

  /// 카드·블록 제목 (19/28, SemiBold)
  static const TextStyle title3 = TextStyle(
    fontFamily: AppFonts.pretendard,
    fontSize: 19,
    height: 28 / 19,
    fontWeight: FontWeight.w600,
    letterSpacing: 19 * -0.01,
  );

  /// 넉넉한 본문 (17/27, Regular)
  static const TextStyle bodyLg = TextStyle(
    fontFamily: AppFonts.pretendard,
    fontSize: 17,
    height: 27 / 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 17 * -0.005,
  );

  /// 기본 본문 (15/24, Regular)
  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.pretendard,
    fontSize: 15,
    height: 24 / 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 15 * -0.003,
  );

  /// 라벨·버튼 (14/20, SemiBold)
  static const TextStyle label = TextStyle(
    fontFamily: AppFonts.pretendard,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// 캡션·메타 (13/18, Regular)
  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.pretendard,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
}
