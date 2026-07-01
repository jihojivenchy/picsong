import 'package:flutter/animation.dart';

/// 픽송 모션 토큰 — 절제되지만 만족스러운 피드백.
/// 시그니처는 이미지 리빌(fade+settle)과 스켈레톤 시머.
abstract final class AppMotion {
  /// 프레스·호버·토글
  static const Duration durationFast = Duration(milliseconds: 140);

  /// 대부분의 전환·페이드
  static const Duration durationBase = Duration(milliseconds: 220);

  /// 이미지 리빌·시트 등장
  static const Duration durationSlow = Duration(milliseconds: 360);

  /// 스켈레톤 시머 1주기 — "기대되는 순간" 로딩
  static const Duration shimmer = Duration(milliseconds: 1400);

  /// 대부분 UI 이동
  static const Cubic standard = Cubic(0.4, 0, 0.2, 1);

  /// 리빌·등장 강조
  static const Cubic emphasized = Cubic(0.2, 0, 0, 1);

  /// 들어오는 요소
  static const Cubic decelerate = Cubic(0, 0, 0.2, 1);

  /// 나가는 요소
  static const Cubic accelerate = Cubic(0.4, 0, 1, 1);

  /// 버튼·카드 프레스 스케일 (Toss)
  static const double pressScale = 0.97;

  /// 보조·아이콘 프레스 불투명도
  static const double pressOpacity = 0.92;
}
