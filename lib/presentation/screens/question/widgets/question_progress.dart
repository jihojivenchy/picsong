import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

/// 라운드 진행 바 — 5개 세그먼트를 현재 문제까지 시대색으로 채운다.
class QuestionProgress extends StatelessWidget {
  /// 세그먼트 간 간격
  static const double _segmentGap = 6;

  /// 세그먼트 높이
  static const double _segmentHeight = 6;

  /// 전체 문제 수
  final int totalSteps;

  /// 현재 문제 인덱스 (0-based)
  final int currentStep;

  /// 채움 색 (시대 강조색)
  final Color fillColor;

  const QuestionProgress({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < totalSteps; i++) ...<Widget>[
          if (i > 0) const Gap(width: _segmentGap),
          Expanded(child: _buildSegment(filled: i <= currentStep)),
        ],
      ],
    );
  }

  /// 세그먼트 1칸
  Widget _buildSegment({required bool filled}) {
    return Container(
      height: _segmentHeight,
      decoration: BoxDecoration(
        color: filled ? fillColor : AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
  }
}
