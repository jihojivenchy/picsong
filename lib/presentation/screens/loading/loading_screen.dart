import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/presentation/common/base/base_screen.dart';
import 'package:picsong/presentation/common/extensions/era_extension.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';
import 'package:picsong/presentation/screens/loading/loading_controller.dart';
import 'package:picsong/presentation/screens/loading/widgets/era_progress_bar.dart';
import 'package:picsong/presentation/screens/loading/widgets/generation_canvas.dart';

/// 로딩(그림 생성 중) 화면
class LoadingScreen extends BaseScreen<LoadingController> {
  /// 생성 대상 시대
  final Era era;

  const LoadingScreen({super.key, required this.era});

  /// 뷰모델 초기화
  @override
  void onInit(BuildContext context) {
    super.onInit(context);
    Get.put(LoadingController(era: era));
  }

  /// 뷰모델 해제
  @override
  void onDispose(BuildContext context) {
    Get.delete<LoadingController>();
    super.onDispose(context);
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: AppText(
                text: era.trivia,
                textAlign: TextAlign.center,
                style: AppTypography.body,
                color: AppColors.textMuted,
              ),
            ),
            const Gap(height: AppSpacing.xxl),
            EraProgressBar(
              fillColor: era.color,
              duration: LoadingController.generationDuration,
            ),
          ],
        ),
      ),
    );
  }
}
