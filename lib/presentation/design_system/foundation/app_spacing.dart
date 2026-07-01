/// 간격 토큰 (4-그리드 스케일)
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// 화면 좌우 기본 여백
  static const double screenHorizontal = 20;

  /// 최소 터치 타깃 (WCAG AA)
  static const double touchMin = 44;

  /// 히어로 이미지 액자 패딩
  static const double imageFramePad = 8;

  /// 모바일 콘텐츠 최대 폭
  static const double contentMax = 480;
}
