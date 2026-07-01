import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/song/song.dart';
import 'package:picsong/presentation/common/base/base_screen.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/image/cached_image.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_shadows.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/screens/reveal/reveal_controller.dart';
import 'package:picsong/presentation/screens/reveal/widgets/reveal_header.dart';
import 'package:picsong/presentation/screens/reveal/widgets/reveal_song_card.dart';

/// 정답 공개(reveal) 화면 — 결과 헤더 + AI 그림 + 정답 곡 정보.
class RevealScreen extends BaseScreen<RevealController> {
  /// 진행 중인 시대
  final Era era;

  /// 공개할 정답 곡
  final Song song;

  /// 정답을 맞혔는지 여부 (false면 답안 공개)
  final bool isCorrect;

  /// 마지막 문제 여부 (true면 '결과 보기')
  final bool isLast;

  /// '다음 문제'/'결과 보기' 진행 콜백
  final VoidCallback onNext;

  const RevealScreen({
    super.key,
    required this.era,
    required this.song,
    required this.isCorrect,
    required this.isLast,
    required this.onNext,
  });

  /// 뷰모델 초기화
  @override
  void onInit(BuildContext context) {
    super.onInit(context);
    Get.put(RevealController(onNext: onNext));
  }

  /// 뷰모델 해제
  @override
  void onDispose(BuildContext context) {
    Get.delete<RevealController>();
    super.onDispose(context);
  }

  /// 하단 고정 진행 버튼
  @override
  Widget? buildBottomNavigationBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.xl,
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
        ),
        child: AppButton(
          text: isLast ? '결과 보기' : '다음 문제',
          margin: 0,
          onTapped: viewModel.goNext,
        ),
      ),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RevealHeader(isCorrect: isCorrect),
          Expanded(child: _buildImage()),
          const Gap(height: AppSpacing.lg),
          RevealSongCard(era: era, song: song),
        ],
      ),
    );
  }

  /// AI 그림 — 생성 이미지 미연동이라 빈 URL이면 스켈레톤으로 대기
  Widget _buildImage() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.elevationImage,
      ),
      child: const CachedImage(
        imageURL: '',
        width: double.infinity,
        height: double.infinity,
        borderRadius: AppRadius.xl,
      ),
    );
  }
}
