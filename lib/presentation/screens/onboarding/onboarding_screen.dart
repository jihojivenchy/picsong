import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/presentation/common/base/legacy_base_screen.dart';
import 'package:picsong/presentation/common/services/dialog_service.dart';
import 'package:picsong/presentation/design_system/components/dialog/app_dialog.dart';
import 'package:picsong/presentation/screens/onboarding/onboarding_controller.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/onboarding_top_bar.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/steps/download/onboarding_download_gate_step.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/steps/download/onboarding_downloading_step.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/steps/intro/onboarding_intro_step.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/steps/second/onboarding_on_device_step.dart';

/// 온보딩(최초 1회) 화면 — 4스텝을 한 화면 안에서 전환한다
class OnboardingScreen extends LegacyBaseScreen<OnboardingController> {
  const OnboardingScreen({super.key});

  /// 뷰모델 초기화
  @override
  void onInit(BuildContext context) {
    super.onInit(context);
    Get.put(OnboardingController());
  }

  /// 뷰모델 해제
  @override
  void onDispose(BuildContext context) {
    Get.delete<OnboardingController>();
    super.onDispose(context);
  }

  /// 화면 본문
  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: <Widget>[
        Obx(
          () => OnboardingTopBar(
            progress: viewModel.step.value.progress,
            onSkip: viewModel.step.value.canSkip
                ? viewModel.onSkipPressed
                : null,
          ),
        ),
        Expanded(
          child: PageView(
            controller: viewModel.pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              OnboardingIntroStep(onNext: viewModel.onNextPressed),
              OnboardingOnDeviceStep(onNext: viewModel.onNextPressed),
              OnboardingDownloadGateStep(onDownload: _showDownloadConfirmDialog),
              Obx(
                () => OnboardingDownloadingStep(
                  progress: viewModel.installProgress.value,
                  onRetry: viewModel.onRetryPressed,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ///
  /// 다운로드 시작 전 확인 다이얼로그 — 동의하면 뷰모델 다운로드를 시작한다
  ///
  void _showDownloadConfirmDialog() {
    DialogService.show(
      dialog: AppDialog.doubleButton(
        title: '다운로드 확인',
        subTitle: '다운로드 중에는 데이터가 사용될 수 있어요.\nWi-Fi 환경에서 받는 것을 권장합니다.',
        leftButtonContent: '취소',
        rightButtonContent: '다운로드',
        onLeftButtonTapped: DialogService.close,
        onRightButtonTapped: () {
          DialogService.close();
          viewModel.onDownloadPressed();
        },
      ),
    );
  }
}
