import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/presentation/common/base/legacy_base_screen.dart';
import 'package:picsong/presentation/common/extensions/era_extension.dart';
import 'package:picsong/presentation/design_system/components/bar/default_app_bar.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';
import 'package:picsong/presentation/screens/round_preparation/round_preparation_controller.dart';
import 'package:picsong/presentation/screens/round_preparation/widgets/preparation_progress_bar.dart';
import 'package:picsong/presentation/screens/round_preparation/widgets/generation_canvas.dart';
import 'package:picsong/presentation/screens/round_preparation/widgets/preparation_caption.dart';

/// 라운드 준비 화면 — 곡을 뽑고 첫 클루 이미지를 생성하는 동안 보여준다
class RoundPreparationScreen extends LegacyBaseScreen<RoundPreparationController> {
  /// 생성 대상 시대
  final Era era;

  const RoundPreparationScreen({super.key, required this.era});

  /// 뷰모델 초기화
  @override
  void onInit(BuildContext context) {
    super.onInit(context);
    Get.put(RoundPreparationController(era: era));
  }

  /// 뷰모델 해제
  @override
  void onDispose(BuildContext context) {
    Get.delete<RoundPreparationController>();
    super.onDispose(context);
  }

  /// 닫기 버튼만 둔 앱바 — 나가도 다운로드는 백그라운드에서 계속된다
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return const DefaultAppBar(
      title: '그림 생성',
      centerTitle: true,
      backgroundColor: AppColors.surfaceCanvas,
    );
  }

  /// 화면 본문
  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GenerationCanvas(accentColor: era.color),
            const Gap(height: AppSpacing.xxl),
            AppText(
              text: '그림을 그리고 있어요',
              textAlign: TextAlign.center,
              style: AppTypography.title2,
              color: AppColors.textStrong,
            ),
            const Gap(height: AppSpacing.sm),
            PreparationCaption(trivia: era.trivia),
            const Gap(height: AppSpacing.xxl),
            PreparationProgressBar(fillColor: era.color),
          ],
        ),
      ),
    );
  }
}
