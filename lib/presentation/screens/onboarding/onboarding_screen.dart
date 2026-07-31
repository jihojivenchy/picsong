import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/presentation/common/base/base_screen.dart';
import 'package:picsong/presentation/screens/onboarding/onboarding_controller.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/onboarding_top_bar.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/steps/onboarding_intro_step.dart';

/// 온보딩(최초 1회) 화면 — 4스텝을 한 화면 안에서 전환한다
class OnboardingScreen extends BaseScreen<OnboardingController> {
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
              const SizedBox.shrink(), // Step 2 — 온디바이스 AI 설명
              const SizedBox.shrink(), // Step 3 — 다운로드 안내 + 동의
              const SizedBox.shrink(), // Step 4 — 다운로드 진행 상태
            ],
          ),
        ),
      ],
    );
  }
}
