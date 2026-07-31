import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:picsong/data/database/hive_service.dart';
import 'package:picsong/presentation/design_system/foundation/app_motion.dart';
import 'package:picsong/presentation/screens/home/home_screen.dart';
import 'package:picsong/presentation/screens/onboarding/onboarding_step.dart';

/// 온보딩(최초 1회) 컨트롤러
class OnboardingController extends GetxController {
  /// 현재 스텝
  final Rx<OnboardingStep> step = Rx<OnboardingStep>(OnboardingStep.intro);

  /// 스텝 본문 전환 — 스와이프가 아닌 버튼 조작으로만 움직인다
  final PageController pageController = PageController();

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  ///
  /// 다음 스텝으로 이동
  ///
  void onNextPressed() {
    final OnboardingStep? next = _nextStep(step.value);
    if (next == null) return;
    _moveTo(next);
  }

  ///
  /// 온보딩 건너뛰기 — 완료로 기록하고 홈으로 보낸다(모델은 없는 상태)
  ///
  Future<void> onSkipPressed() async {
    await _markCompleted();
    Get.offAll(() => const HomeScreen());
  }

  ///
  /// 다음 스텝 계산 — 마지막 스텝이면 null
  ///
  OnboardingStep? _nextStep(OnboardingStep current) {
    final int nextIndex = current.index + 1;
    if (nextIndex >= OnboardingStep.values.length) return null;
    return OnboardingStep.values[nextIndex];
  }

  ///
  /// 스텝 상태와 본문 페이지를 함께 이동
  ///
  void _moveTo(OnboardingStep target) {
    step.value = target;
    pageController.animateToPage(
      target.index,
      duration: AppMotion.durationBase,
      curve: AppMotion.emphasized,
    );
  }

  ///
  /// 온보딩 완료 기록 — 다음 실행부터는 홈으로 바로 진입한다
  ///
  Future<void> _markCompleted() {
    return HiveService.instance.create(
      HiveBoxPath.onboardingCompleted,
      value: true,
    );
  }
}
