import 'dart:io';

import 'package:flutter/material.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/question/question.dart';
import 'package:picsong/presentation/common/base/base_screen.dart';
import 'package:picsong/presentation/design_system/components/bar/default_app_bar.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/skeleton/skeleton_box.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_shadows.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/screens/question/result/widgets/question_result_header.dart';
import 'package:picsong/presentation/screens/question/result/widgets/question_result_song_card.dart';

/// 문제 결과 화면 — 정오 헤더 + 출제된 클루 그림 + 정답 곡·가사.
class QuestionResultScreen extends BaseScreen {
  /// 진행 중인 시대
  final Era era;

  /// 공개할 문제 — 정답 곡과 출제된 가사
  final Question question;

  /// 문제에서 보여준 클루 이미지 경로 — 비어 있으면 스켈레톤
  final String imagePath;

  /// 정답을 맞혔는지 여부 (false면 답안 공개)
  final bool isCorrect;

  /// 마지막 문제 여부 (true면 '결과 보기')
  final bool isLast;

  /// '다음 문제'/'결과 보기' 진행 콜백
  final VoidCallback onNext;

  const QuestionResultScreen({
    super.key,
    required this.era,
    required this.question,
    required this.imagePath,
    required this.isCorrect,
    required this.isLast,
    required this.onNext,
  });

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return DefaultAppBar(
      title: '결과',
      centerTitle: true,
      titleColor: AppColors.textStrong,
      backgroundColor: AppColors.surfaceCanvas,
    );
  }

  /// 화면 본문 — 헤더 + 히어로 이미지(가변 높이) + 곡 카드
  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  QuestionResultHeader(isCorrect: isCorrect),
                  _buildImage(),
                  const Gap(height: AppSpacing.lg),
                  QuestionResultSongCard(era: era, question: question),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
            ),
            child: AppButton(
              text: isLast ? '결과 보기' : '다음 문제',
              margin: 0,
              onTapped: onNext,
            ),
          ),
        ],
      ),
    );
  }

  /// 문제에서 보여준 클루 그림 — 경로가 없거나 읽지 못하면 스켈레톤
  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.elevationImage,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: imagePath.isEmpty ? _buildSkeleton() : _buildClueImage(),
        ),
      ),
    );
  }

  /// 생성된 클루 이미지(로컬 파일)
  Widget _buildClueImage() {
    return Image.file(
      File(imagePath),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) =>
          _buildSkeleton(),
    );
  }

  /// 이미지 대기·실패 시 자리 표시
  Widget _buildSkeleton() => const SkeletonBox(borderRadius: AppRadius.xl);
}
