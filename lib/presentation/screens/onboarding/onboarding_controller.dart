import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:picsong/data/database/hive_service.dart';
import 'package:picsong/data/dio/error/error_exception_type.dart';
import 'package:picsong/data/services/model/model_install_service.dart';
import 'package:picsong/domain/entities/model_install/model_install_progress.dart';
import 'package:picsong/domain/entities/model_install/model_install_state.dart';
import 'package:picsong/presentation/design_system/foundation/app_motion.dart';
import 'package:picsong/presentation/screens/home/home_screen.dart';
import 'package:picsong/presentation/screens/onboarding/onboarding_step.dart';
import 'package:picsong/utils/services/app_logger.dart';

/// 온보딩(최초 1회) 컨트롤러
class OnboardingController extends GetxController {
  /// 현재 스텝
  final Rx<OnboardingStep> step = Rx<OnboardingStep>(OnboardingStep.intro);

  /// 페이지 컨트롤러
  final PageController pageController = PageController(
    initialPage: OnboardingStep.intro.index,
  );

  /// 모델 설치 진행 스냅샷
  final Rx<ModelInstallProgress> installProgress =
      Rx<ModelInstallProgress>(ModelInstallProgress.initialState);

  /// 모델 설치 서비스
  final ModelInstallService _modelInstallService = ModelInstallService();

  /// 진행률 구독
  StreamSubscription<ModelInstallProgress>? _progressSubscription;

  @override
  void onInit() {
    super.onInit();
    if (step.value == OnboardingStep.downloading) _startInstall();
  }

  @override
  void onClose() {
    _progressSubscription?.cancel();
    pageController.dispose();
    super.onClose();
  }

  ///
  /// 온보딩 건너뛰기 — 완료로 기록하고 홈으로 보낸다(모델은 없는 상태)
  ///
  Future<void> onSkipPressed() async {
    await _markCompleted();
    Get.offAll(() => const HomeScreen());
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
  /// Step 3 동의 — 진행 화면으로 이동하고 다운로드를 시작
  ///
  void onDownloadPressed() {
    _moveTo(OnboardingStep.downloading);
    _startInstall();
  }

  ///
  /// 진행률 구독을 붙이고 네이티브 다운로드·설치를 시작
  ///
  Future<void> _startInstall() async {
    _progressSubscription ??= _modelInstallService.progressStream().listen(
          _onProgress,
          onError: _onInstallError,
        );
    try {
      await _modelInstallService.startInstall();
    } on ModelInstallException catch (error) {
      _onInstallError(error);
    }
  }

  ///
  /// 진행 스냅샷 반영
  ///
  void _onProgress(ModelInstallProgress progress) {
    installProgress.value = progress;

    // 설치 완료 시 온보딩 완료 기록 후 홈으로
    if (progress.state == ModelInstallState.ready) _completeAndGoHome();
  }

  ///
  /// 설치 실패 반영
  ///
  void _onInstallError(Object error) {
    AppLogger.error('모델 설치 실패', error: error);
    installProgress.value =
        installProgress.value.copyWith(state: ModelInstallState.failed);
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
  /// 실패 후 재시도
  ///
  void onRetryPressed() => _startInstall();

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
  /// 온보딩 완료 기록 후 홈으로 — 곧장 게임으로 보내지 않는다
  ///
  Future<void> _completeAndGoHome() async {
    await _markCompleted();
    Get.offAll(() => const HomeScreen());
  }

  ///
  /// 온보딩 완료 기록
  ///
  Future<void> _markCompleted() {
    return HiveService.instance.create(
      HiveBoxPath.onboardingCompleted,
      value: true,
    );
  }
}
