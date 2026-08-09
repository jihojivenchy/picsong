import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/data/database/hive_service.dart';
import 'package:picsong/data/dio/error/error_exception_type.dart';
import 'package:picsong/data/services/model/model_install_service.dart';
import 'package:picsong/domain/entities/model_install/model_install_progress.dart';
import 'package:picsong/domain/entities/model_install/model_install_state.dart';
import 'package:picsong/presentation/design_system/foundation/app_motion.dart';
import 'package:picsong/presentation/screens/onboarding/onboarding_step.dart';
import 'package:picsong/utils/services/app_logger.dart';

part 'onboarding_state.dart';

/// 온보딩(최초 1회) 뷰모델
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  /// 모델 설치 서비스
  final ModelInstallService _modelInstallService = ModelInstallService();

  /// 페이지 컨트롤러 — 스텝 전환과 본문 페이지가 함께 움직인다
  final PageController pageController = PageController(
    initialPage: OnboardingStep.intro.index,
  );

  /// 진행률 구독
  StreamSubscription<ModelInstallProgress>? _progressSubscription;

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    pageController.dispose();
    return super.close();
  }

  ///
  /// 다음 스텝으로 이동
  ///
  void onNextPressed() {
    final OnboardingStep? next = _nextStep(state.step);
    if (next == null) return;
    _moveTo(next);
  }

  ///
  /// Step 3 동의 — 진행 화면으로 이동하고 다운로드를 시작
  ///
  void onDownloadPressed() {
    _moveTo(OnboardingStep.downloading);
    startInstall();
  }

  ///
  /// 진행률 구독을 붙이고 네이티브 다운로드·설치를 시작 — 실패 후 재시도도 같은 경로를 탄다
  ///
  Future<void> startInstall() async {
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
  /// 온보딩 완료 처리 — 건너뛰기와 설치 완료가 함께 쓰는 종료 경로
  ///
  Future<void> completeOnboarding() async {
    await HiveService.instance.create(
      HiveBoxPath.onboardingCompleted,
      value: true,
    );
    if (isClosed) return;
    emit(state.copyWith(isCompleted: true));
  }

  ///
  /// 진행 스냅샷 반영 — 설치가 끝나면 온보딩을 완료 처리한다
  ///
  void _onProgress(ModelInstallProgress progress) {
    _setProgress(progress);
    if (progress.state == ModelInstallState.ready) completeOnboarding();
  }

  ///
  /// 설치 실패 반영
  ///
  void _onInstallError(Object error) {
    AppLogger.error('모델 설치 실패', error: error);
    _setProgress(
      state.installProgress.copyWith(state: ModelInstallState.failed),
    );
  }

  ///
  /// 진행 스냅샷 반영 — 화면이 닫힌 뒤 도착한 이벤트는 버린다
  ///
  void _setProgress(ModelInstallProgress progress) {
    if (isClosed) return;
    emit(state.copyWith(installProgress: progress));
  }

  ///
  /// 스텝 상태와 본문 페이지를 함께 이동
  ///
  void _moveTo(OnboardingStep target) {
    emit(state.copyWith(step: target));
    pageController.animateToPage(
      target.index,
      duration: AppMotion.durationBase,
      curve: AppMotion.emphasized,
    );
  }

  ///
  /// 다음 스텝 계산 — 마지막 스텝이면 null
  ///
  OnboardingStep? _nextStep(OnboardingStep current) {
    final int nextIndex = current.index + 1;
    if (nextIndex >= OnboardingStep.values.length) return null;
    return OnboardingStep.values[nextIndex];
  }
}
