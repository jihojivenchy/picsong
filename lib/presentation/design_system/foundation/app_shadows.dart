import 'package:flutter/material.dart';

/// 픽송 엘리베이션 — 낮고 따뜻한 그림자 (border가 구조를 보조).
/// 워밍 틴트(#211D18) · 낮은 불투명도. 라이트 전용.
abstract final class AppShadows {
  /// 카드 기본 — 아주 낮은 리프트
  static const List<BoxShadow> elevation1 = [
    BoxShadow(color: Color(0x0D211D18), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x0A211D18), offset: Offset(0, 1), blurRadius: 3),
  ];

  /// 떠 있는 컨트롤·드롭다운
  static const List<BoxShadow> elevation2 = [
    BoxShadow(color: Color(0x0F211D18), offset: Offset(0, 2), blurRadius: 8),
    BoxShadow(color: Color(0x0A211D18), offset: Offset(0, 1), blurRadius: 2),
  ];

  /// 모달·팝오버
  static const List<BoxShadow> elevation3 = [
    BoxShadow(color: Color(0x1A211D18), offset: Offset(0, 10), blurRadius: 28),
    BoxShadow(color: Color(0x0D211D18), offset: Offset(0, 2), blurRadius: 6),
  ];

  /// 히어로 이미지 액자 전용 리프트
  static const List<BoxShadow> elevationImage = [
    BoxShadow(color: Color(0x14211D18), offset: Offset(0, 4), blurRadius: 16),
    BoxShadow(color: Color(0x0D211D18), offset: Offset(0, 1), blurRadius: 3),
  ];
}
