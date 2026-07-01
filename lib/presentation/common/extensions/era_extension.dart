import 'package:flutter/material.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';

/// 시대별 색 토큰 매핑.
extension EraColor on Era {
  /// 워터마크·강조 색
  Color get color => switch (this) {
        Era.era80s => AppColors.era80s,
        Era.era90s => AppColors.era90s,
        Era.era00s => AppColors.era00s,
        Era.era10s => AppColors.era10s,
        Era.era20s => AppColors.era20s,
      };

  /// 카드 배경 색
  Color get softColor => switch (this) {
        Era.era80s => AppColors.era80sSoft,
        Era.era90s => AppColors.era90sSoft,
        Era.era00s => AppColors.era00sSoft,
        Era.era10s => AppColors.era10sSoft,
        Era.era20s => AppColors.era20sSoft,
      };
}

/// 시대별 로딩 화면 카피 매핑.
extension EraCopy on Era {
  /// 로딩 중 보여줄 시대 트리비아
  String get trivia => switch (this) {
        Era.era80s => '1980년대엔 라디오 음악 신청엽서가 큰 인기였어요.',
        Era.era90s => '1990년대는 가요 순위 프로그램의 황금기였죠.',
        Era.era00s => '2000년대 초반엔 컬러링과 벨소리가 유행했어요.',
        Era.era10s => '2010년대엔 음원 스트리밍이 본격화됐어요.',
        Era.era20s => '2020년대는 숏폼으로 노래가 다시 유행하곤 해요.',
      };
}
