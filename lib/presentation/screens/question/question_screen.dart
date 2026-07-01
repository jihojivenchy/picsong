import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/presentation/common/base/base_screen.dart';
import 'package:picsong/presentation/common/extensions/era_extension.dart';
import 'package:picsong/presentation/design_system/components/bar/default_app_bar.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';
import 'package:picsong/presentation/screens/question/question_controller.dart';
import 'package:picsong/presentation/screens/question/widgets/hint_bottom_sheet.dart';
import 'package:picsong/presentation/screens/question/widgets/question_actions.dart';
import 'package:picsong/presentation/screens/question/widgets/question_image.dart';
import 'package:picsong/presentation/screens/question/widgets/question_input_bar.dart';
import 'package:picsong/presentation/screens/question/widgets/question_progress.dart';

/// 퀴즈(문제 풀이) 화면
class QuestionScreen extends BaseScreen<QuestionController> {
  /// 진행할 시대
  final Era era;

  const QuestionScreen({super.key, required this.era});

  /// 뷰모델 초기화
  @override
  void onInit(BuildContext context) {
    super.onInit(context);
    Get.put(QuestionController(era: era));
  }

  /// 뷰모델 해제
  @override
  void onDispose(BuildContext context) {
    Get.delete<QuestionController>();
    super.onDispose(context);
  }

  /// 닫기(X) + 가운데 시대명
  @override
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return DefaultAppBar(
      title: era.label,
      centerTitle: true,
      titleColor: AppColors.textStrong,
      backButtonType: BackButtonType.xmark,
      backgroundColor: AppColors.surfaceCanvas,
    );
  }

  /// 화면 본문
  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.xs,
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                ),
                child: Obx(
                  () => QuestionProgress(
                    totalSteps: QuestionController.totalQuestions,
                    currentStep: viewModel.qIndex.value,
                    fillColor: era.color,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal),
                // 생성 이미지 미연동 — 빈 URL이면 CachedImage가 대기(스켈레톤) 표시
                child: QuestionImage(imageURL: ''),
              ),
              Expanded(
                child: _buildPrompt(context),
              ),
            ],
          ),
        ),
        QuestionInputBar(onSubmit: viewModel.submit),
      ],
    );
  }

  /// 질문 문구 + 보조 액션 (스크롤 영역)
  Widget _buildPrompt(BuildContext context) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        children: <Widget>[
          const Gap(height: AppSpacing.lg),
          AppText(
            text: '이 그림이 떠올리게 하는 노래는?',
            style: AppTypography.title3,
            color: AppColors.textStrong,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const Gap(height: AppSpacing.lg),
          Obx(
            () => QuestionActions(
              hintUsed: viewModel.hintUsed.value,
              onHintTapped: () => _openHint(context),
              onRevealTapped: viewModel.revealAnswer,
            ),
          ),
        ],
      ),
    );
  }

  /// 힌트 사용 처리 후 힌트 시트 표시
  void _openHint(BuildContext context) {
    viewModel.useHint();
    HintBottomSheet.show(context, hints: viewModel.currentHints);
  }
}
