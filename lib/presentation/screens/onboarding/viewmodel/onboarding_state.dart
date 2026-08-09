part of 'onboarding_cubit.dart';

/// 온보딩 화면 상태
final class OnboardingState extends Equatable {
  /// 현재 스텝
  final OnboardingStep step;

  /// 모델 설치 진행 스냅샷
  final ModelInstallProgress installProgress;

  /// 온보딩 완료 기록까지 끝난 상태 — 홈 이동 신호
  final bool isCompleted;

  const OnboardingState({
    this.step = OnboardingStep.intro,
    this.installProgress = const ModelInstallProgress(
      state: ModelInstallState.notInstalled,
      receivedBytes: 0,
      totalBytes: 0,
    ),
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    OnboardingStep? step,
    ModelInstallProgress? installProgress,
    bool? isCompleted,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      installProgress: installProgress ?? this.installProgress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => <Object?>[step, installProgress, isCompleted];
}
