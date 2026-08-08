import 'dart:io';

import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/screens/prompt_lab/prompt_lab_batch.dart';

/// 실험 한 건의 결과 — 라벨·이미지·보낸 프롬프트를 한 덩어리로 보여준다
class PromptTrialItem extends StatelessWidget {
  /// 이미지 한 변의 크기 — 생성 해상도와 맞춘다
  static const double _imageSize = 240;

  /// 표시할 실험 결과
  final PromptTrial trial;

  const PromptTrialItem({super.key, required this.trial});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppText(
          text: trial.label,
          color: AppColors.textStrong,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          maxLines: 2,
          overflow: TextOverflow.visible,
        ),
        const Gap(height: AppSpacing.sm),
        _buildImage(),
        const Gap(height: AppSpacing.sm),
        AppText(
          text: trial.prompt,
          color: AppColors.textMuted,
          fontSize: 12,
          maxLines: 6,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }

  /// 생성 결과 영역 — 대기·실패·성공 세 상태
  Widget _buildImage() {
    if (trial.error.isNotEmpty) {
      return _buildPlaceholder(text: '실패: ${trial.error}');
    }
    if (trial.imagePath.isEmpty) {
      return _buildPlaceholder(text: '대기 중');
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.file(
        File(trial.imagePath),
        width: _imageSize,
        height: _imageSize,
        fit: BoxFit.cover,
      ),
    );
  }

  /// 이미지 자리를 채우는 안내 상자
  Widget _buildPlaceholder({required String text}) {
    return Container(
      width: _imageSize,
      height: _imageSize,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: AppText(
        text: text,
        color: AppColors.textMuted,
        fontSize: 13,
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.visible,
      ),
    );
  }
}
